//! Checked Vulkan vector addition on a physical compute device.
use ash::{vk, Entry};
use std::{ffi::CStr, io::Cursor};

type Result<T> = std::result::Result<T, String>;

/// Deterministic, exactly representable inputs independent of the shader.
pub fn inputs(n: usize) -> (Vec<f32>, Vec<f32>) {
    (
        (0..n).map(|i| (i % 127) as f32 - 63.0).collect(),
        (0..n).map(|i| (i % 31) as f32 * 0.25 - 4.0).collect(),
    )
}

/// Check every output; reject shape mismatches and nonfinite values.
pub fn check_output(a: &[f32], b: &[f32], actual: &[f32]) -> Result<()> {
    if a.len() != b.len() || a.len() != actual.len() {
        return Err("vector-add shape mismatch".into());
    }
    for (i, ((a, b), got)) in a.iter().zip(b).zip(actual).enumerate() {
        let expected = a + b;
        if !got.is_finite() || *got != expected {
            return Err(format!("element {i}: got {got}, expected {expected}"));
        }
    }
    Ok(())
}

fn vk_result<T>(r: std::result::Result<T, vk::Result>) -> Result<T> {
    r.map_err(|e| format!("Vulkan: {e:?}"))
}

fn name(bytes: &[std::ffi::c_char]) -> String {
    // Vulkan fixed-size names are NUL terminated by the driver.
    unsafe { CStr::from_ptr(bytes.as_ptr()) }
        .to_string_lossy()
        .into_owned()
}

// Own every handle as soon as it is created, including partial initialization.
struct Resources {
    _entry: Entry,
    instance: ash::Instance,
    device: Option<ash::Device>,
    buffers: Vec<vk::Buffer>,
    memory: Vec<vk::DeviceMemory>,
    shader: vk::ShaderModule,
    descriptors: vk::DescriptorSetLayout,
    layout: vk::PipelineLayout,
    pipeline: vk::Pipeline,
    pool: vk::DescriptorPool,
    commands: vk::CommandPool,
    fence: vk::Fence,
}

impl Drop for Resources {
    fn drop(&mut self) {
        // Completion (or device loss) precedes freeing any submitted resource.
        unsafe {
            if let Some(d) = &self.device {
                let _ = d.device_wait_idle();
                d.destroy_fence(self.fence, None);
                d.destroy_command_pool(self.commands, None);
                d.destroy_descriptor_pool(self.pool, None);
                d.destroy_pipeline(self.pipeline, None);
                d.destroy_pipeline_layout(self.layout, None);
                d.destroy_descriptor_set_layout(self.descriptors, None);
                d.destroy_shader_module(self.shader, None);
                for &b in &self.buffers {
                    d.destroy_buffer(b, None);
                }
                for &m in &self.memory {
                    d.free_memory(m, None);
                }
                d.destroy_device(None);
            }
            self.instance.destroy_instance(None);
        }
    }
}

/// Dispatch vector addition and verify every element. CPU Vulkan devices are
/// listed for diagnosis but never selected. Supports 1 through 1M elements.
pub fn run_vector_add(n: usize) -> Result<()> {
    if !(1..=1048576).contains(&n) {
        return Err("count must be between 1 and 1048576".into());
    }
    // All Vulkan pointers below refer to live arrays for the duration of each
    // call. Resources owns the resulting handles through completion/readback.
    unsafe {
        let entry = Entry::load().map_err(|e| e.to_string())?;
        let extensions = vk_result(entry.enumerate_instance_extension_properties(None))?;
        let portability = extensions.iter().any(|e| {
            CStr::from_ptr(e.extension_name.as_ptr()) == ash::khr::portability_enumeration::NAME
        });
        let extension_names = if portability {
            vec![ash::khr::portability_enumeration::NAME.as_ptr()]
        } else {
            vec![]
        };
        let app = vk::ApplicationInfo::default()
            .application_name(c"adreno-vk")
            .api_version(vk::API_VERSION_1_1);
        let create = vk::InstanceCreateInfo::default()
            .application_info(&app)
            .enabled_extension_names(&extension_names)
            .flags(if portability {
                vk::InstanceCreateFlags::ENUMERATE_PORTABILITY_KHR
            } else {
                vk::InstanceCreateFlags::empty()
            });
        let instance = vk_result(entry.create_instance(&create, None))?;
        let mut r = Resources {
            _entry: entry,
            instance,
            device: None,
            buffers: vec![],
            memory: vec![],
            shader: vk::ShaderModule::null(),
            descriptors: vk::DescriptorSetLayout::null(),
            layout: vk::PipelineLayout::null(),
            pipeline: vk::Pipeline::null(),
            pool: vk::DescriptorPool::null(),
            commands: vk::CommandPool::null(),
            fence: vk::Fence::null(),
        };
        let mut selected = None;
        for physical in vk_result(r.instance.enumerate_physical_devices())? {
            let props = r.instance.get_physical_device_properties(physical);
            let device_extensions =
                vk_result(r.instance.enumerate_device_extension_properties(physical))?;
            let driver_props = props.api_version >= vk::API_VERSION_1_2
                || device_extensions.iter().any(|e| {
                    CStr::from_ptr(e.extension_name.as_ptr()) == ash::khr::driver_properties::NAME
                });
            let driver = if driver_props {
                let mut driver = vk::PhysicalDeviceDriverProperties::default();
                let mut properties =
                    vk::PhysicalDeviceProperties2::default().push_next(&mut driver);
                r.instance
                    .get_physical_device_properties2(physical, &mut properties);
                format!(
                    "{} ({})",
                    name(&driver.driver_name),
                    name(&driver.driver_info)
                )
            } else {
                format!(
                    "vendor={:#x}, version={:#x}",
                    props.vendor_id, props.driver_version
                )
            };
            let device_name = name(&props.device_name);
            println!(
                "device: {device_name}; driver: {driver}; type: {:?}",
                props.device_type
            );
            let lower = format!("{device_name} {driver}").to_lowercase();
            let hardware = matches!(
                props.device_type,
                vk::PhysicalDeviceType::DISCRETE_GPU | vk::PhysicalDeviceType::INTEGRATED_GPU
            );
            if !hardware || lower.contains("llvmpipe") || lower.contains("lavapipe") {
                continue;
            }
            if props.api_version < vk::API_VERSION_1_1 {
                continue;
            }
            let families = r
                .instance
                .get_physical_device_queue_family_properties(physical);
            if let Some((index, _)) = families
                .iter()
                .enumerate()
                .find(|(_, q)| q.queue_count > 0 && q.queue_flags.contains(vk::QueueFlags::COMPUTE))
            {
                if selected.is_none() {
                    selected = Some((
                        physical,
                        index as u32,
                        props,
                        device_extensions,
                        device_name,
                        driver,
                    ));
                }
            }
        }
        let (physical, family, props, device_extensions, device_name, driver) =
            selected.ok_or("no physical Vulkan 1.1 compute GPU")?;
        let bytes = (n * std::mem::size_of::<f32>()) as u64;
        let groups = (n as u32).div_ceil(256);
        if props.limits.max_storage_buffer_range < bytes as u32
            || props.limits.max_compute_work_group_invocations < 256
            || props.limits.max_compute_work_group_size[0] < 256
            || props.limits.max_compute_work_group_count[0] < groups
        {
            return Err("device limits do not support this vector-add dispatch".into());
        }
        println!("selected: {device_name}; driver: {driver}; compute queue family: {family}");
        let priorities = [1.0];
        let queues = [vk::DeviceQueueCreateInfo::default()
            .queue_family_index(family)
            .queue_priorities(&priorities)];
        let subset = device_extensions.iter().any(|e| {
            CStr::from_ptr(e.extension_name.as_ptr()) == ash::khr::portability_subset::NAME
        });
        let device_ext = if subset {
            vec![ash::khr::portability_subset::NAME.as_ptr()]
        } else {
            vec![]
        };
        r.device = Some(vk_result(
            r.instance.create_device(
                physical,
                &vk::DeviceCreateInfo::default()
                    .queue_create_infos(&queues)
                    .enabled_extension_names(&device_ext),
                None,
            ),
        )?);
        let d = r.device.as_ref().unwrap();
        let memory_props = r.instance.get_physical_device_memory_properties(physical);
        for _ in 0..3 {
            let buffer = vk_result(
                d.create_buffer(
                    &vk::BufferCreateInfo::default()
                        .size(bytes)
                        .usage(vk::BufferUsageFlags::STORAGE_BUFFER)
                        .sharing_mode(vk::SharingMode::EXCLUSIVE),
                    None,
                ),
            )?;
            r.buffers.push(buffer);
            let req = d.get_buffer_memory_requirements(buffer);
            let flags =
                vk::MemoryPropertyFlags::HOST_VISIBLE | vk::MemoryPropertyFlags::HOST_COHERENT;
            let index = (0..memory_props.memory_type_count)
                .find(|&i| {
                    req.memory_type_bits & (1 << i) != 0
                        && memory_props.memory_types[i as usize]
                            .property_flags
                            .contains(flags)
                })
                .ok_or("no host-visible coherent storage memory")?;
            let memory = vk_result(
                d.allocate_memory(
                    &vk::MemoryAllocateInfo::default()
                        .allocation_size(req.size)
                        .memory_type_index(index),
                    None,
                ),
            )?;
            r.memory.push(memory);
            vk_result(d.bind_buffer_memory(buffer, memory, 0))?;
        }
        let (a, b) = inputs(n);
        for (memory, data) in r.memory.iter().zip([&a, &b]) {
            let ptr = vk_result(d.map_memory(*memory, 0, bytes, vk::MemoryMapFlags::empty()))?;
            std::ptr::copy_nonoverlapping(data.as_ptr(), ptr.cast::<f32>(), n);
            d.unmap_memory(*memory);
        }
        // Poison output so a missing write cannot accidentally pass.
        let ptr = vk_result(d.map_memory(r.memory[2], 0, bytes, vk::MemoryMapFlags::empty()))?;
        std::slice::from_raw_parts_mut(ptr.cast::<f32>(), n).fill(f32::NAN);
        d.unmap_memory(r.memory[2]);
        let bindings: Vec<_> = (0..3)
            .map(|i| {
                vk::DescriptorSetLayoutBinding::default()
                    .binding(i)
                    .descriptor_type(vk::DescriptorType::STORAGE_BUFFER)
                    .descriptor_count(1)
                    .stage_flags(vk::ShaderStageFlags::COMPUTE)
            })
            .collect();
        r.descriptors = vk_result(d.create_descriptor_set_layout(
            &vk::DescriptorSetLayoutCreateInfo::default().bindings(&bindings),
            None,
        ))?;
        let sets = [r.descriptors];
        let push = [vk::PushConstantRange::default()
            .stage_flags(vk::ShaderStageFlags::COMPUTE)
            .size(4)];
        r.layout = vk_result(
            d.create_pipeline_layout(
                &vk::PipelineLayoutCreateInfo::default()
                    .set_layouts(&sets)
                    .push_constant_ranges(&push),
                None,
            ),
        )?;
        let words = ash::util::read_spv(&mut Cursor::new(include_bytes!(concat!(
            env!("OUT_DIR"),
            "/vector_add.spv"
        ))))
        .map_err(|e| e.to_string())?;
        r.shader = vk_result(
            d.create_shader_module(&vk::ShaderModuleCreateInfo::default().code(&words), None),
        )?;
        let stage = vk::PipelineShaderStageCreateInfo::default()
            .stage(vk::ShaderStageFlags::COMPUTE)
            .module(r.shader)
            .name(c"main");
        r.pipeline = match d.create_compute_pipelines(
            vk::PipelineCache::null(),
            &[vk::ComputePipelineCreateInfo::default()
                .stage(stage)
                .layout(r.layout)],
            None,
        ) {
            Ok(pipelines) => pipelines[0],
            Err((pipelines, err)) => {
                for pipeline in pipelines {
                    d.destroy_pipeline(pipeline, None);
                }
                return Err(format!("compute pipeline: {err:?}"));
            }
        };
        let sizes = [vk::DescriptorPoolSize::default()
            .ty(vk::DescriptorType::STORAGE_BUFFER)
            .descriptor_count(3)];
        r.pool = vk_result(
            d.create_descriptor_pool(
                &vk::DescriptorPoolCreateInfo::default()
                    .max_sets(1)
                    .pool_sizes(&sizes),
                None,
            ),
        )?;
        let set = vk_result(
            d.allocate_descriptor_sets(
                &vk::DescriptorSetAllocateInfo::default()
                    .descriptor_pool(r.pool)
                    .set_layouts(&sets),
            ),
        )?[0];
        let infos: Vec<_> = r
            .buffers
            .iter()
            .map(|b| [vk::DescriptorBufferInfo::default().buffer(*b).range(bytes)])
            .collect();
        let writes: Vec<_> = infos
            .iter()
            .enumerate()
            .map(|(i, info)| {
                vk::WriteDescriptorSet::default()
                    .dst_set(set)
                    .dst_binding(i as u32)
                    .descriptor_type(vk::DescriptorType::STORAGE_BUFFER)
                    .buffer_info(info)
            })
            .collect();
        d.update_descriptor_sets(&writes, &[]);
        r.commands = vk_result(d.create_command_pool(
            &vk::CommandPoolCreateInfo::default().queue_family_index(family),
            None,
        ))?;
        let cmd = vk_result(
            d.allocate_command_buffers(
                &vk::CommandBufferAllocateInfo::default()
                    .command_pool(r.commands)
                    .level(vk::CommandBufferLevel::PRIMARY)
                    .command_buffer_count(1),
            ),
        )?[0];
        vk_result(
            d.begin_command_buffer(
                cmd,
                &vk::CommandBufferBeginInfo::default()
                    .flags(vk::CommandBufferUsageFlags::ONE_TIME_SUBMIT),
            ),
        )?;
        d.cmd_bind_pipeline(cmd, vk::PipelineBindPoint::COMPUTE, r.pipeline);
        d.cmd_bind_descriptor_sets(
            cmd,
            vk::PipelineBindPoint::COMPUTE,
            r.layout,
            0,
            &[set],
            &[],
        );
        d.cmd_push_constants(
            cmd,
            r.layout,
            vk::ShaderStageFlags::COMPUTE,
            0,
            &(n as u32).to_ne_bytes(),
        );
        d.cmd_dispatch(cmd, groups, 1, 1);
        let barriers = [vk::MemoryBarrier::default()
            .src_access_mask(vk::AccessFlags::SHADER_WRITE)
            .dst_access_mask(vk::AccessFlags::HOST_READ)];
        d.cmd_pipeline_barrier(
            cmd,
            vk::PipelineStageFlags::COMPUTE_SHADER,
            vk::PipelineStageFlags::HOST,
            vk::DependencyFlags::empty(),
            &barriers,
            &[],
            &[],
        );
        vk_result(d.end_command_buffer(cmd))?;
        r.fence = vk_result(d.create_fence(&vk::FenceCreateInfo::default(), None))?;
        let commands = [cmd];
        vk_result(d.queue_submit(
            d.get_device_queue(family, 0),
            &[vk::SubmitInfo::default().command_buffers(&commands)],
            r.fence,
        ))?;
        vk_result(d.wait_for_fences(&[r.fence], true, 30_000_000_000))?;
        let ptr = vk_result(d.map_memory(r.memory[2], 0, bytes, vk::MemoryMapFlags::empty()))?;
        let output = std::slice::from_raw_parts(ptr.cast::<f32>(), n).to_vec();
        d.unmap_memory(r.memory[2]);
        check_output(&a, &b, &output)?;
        println!("RESULT: {n} of {n} elements match CPU reference; workgroups={groups}");
        Ok(())
    }
}
