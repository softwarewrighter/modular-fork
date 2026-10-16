//! The reference: the program evaluated in Rust, in f32, folding reductions
//! from the right as X_eTaL's `r_/` does. The GPU must reproduce these
//! outputs (exactly for bools, within a tolerance for floats, since the
//! device's tree reduction folds in another order).

use crate::ir::{MapOp, Op, Program, RedOp, Shape, Ty, EXACT_INT};
use std::collections::HashMap;

fn map1(op: MapOp, a: f32) -> f32 {
    match op {
        MapOp::Neg => -a,
        MapOp::Abs => a.abs(),
        MapOp::Exp => a.exp(),
        MapOp::Log => a.ln(),
        MapOp::Not => {
            if a != 0.0 {
                0.0
            } else {
                1.0
            }
        }
        _ => unreachable!(),
    }
}

fn map2(op: MapOp, a: f32, b: f32) -> f32 {
    let bit = |c: bool| if c { 1.0 } else { 0.0 };
    match op {
        MapOp::Add => a + b,
        MapOp::Sub => a - b,
        MapOp::Mul => a * b,
        MapOp::Div => a / b,
        // Floored, as X_eTaL's and Python's: the result takes the divisor's sign.
        MapOp::Mod => a - b * (a / b).floor(),
        MapOp::Min => a.min(b),
        MapOp::Max => a.max(b),
        MapOp::Eq => bit(a == b),
        MapOp::Ne => bit(a != b),
        MapOp::Lt => bit(a < b),
        MapOp::Le => bit(a <= b),
        MapOp::Gt => bit(a > b),
        MapOp::Ge => bit(a >= b),
        MapOp::And => bit(a != 0.0 && b != 0.0),
        MapOp::Or => bit(a != 0.0 || b != 0.0),
        _ => unreachable!(),
    }
}

/// Runs the program; returns one vector per `output` line (a single value as a
/// vector of one; bools as 0 or 1).
pub fn run(p: &Program, inputs: &HashMap<String, Vec<f32>>) -> Result<Vec<Vec<f32>>, String> {
    let mut vals: Vec<Vec<f32>> = Vec::with_capacity(p.values.len());
    for v in &p.values {
        let len = v.len();
        let at = |a: usize, i: usize| -> f32 {
            let x = &vals[a];
            if x.len() == 1 {
                x[0]
            } else {
                x[i]
            }
        };
        let computed: Vec<f32> = match &v.op {
            Op::Input => {
                let given = inputs
                    .get(&v.name)
                    .ok_or_else(|| format!("input %{} is not bound", v.name))?;
                if given.len() != len {
                    return Err(format!(
                        "input %{} has {} items bound, its shape wants {}",
                        v.name,
                        given.len(),
                        len
                    ));
                }
                given.clone()
            }
            Op::Const(items) => {
                if items.len() == 1 {
                    vec![items[0]; len]
                } else {
                    items.clone()
                }
            }
            Op::Map(op, args) => (0..len)
                .map(|i| {
                    if args.len() == 1 {
                        map1(*op, at(args[0], i))
                    } else {
                        map2(*op, at(args[0], i), at(args[1], i))
                    }
                })
                .collect(),
            Op::Select(c, a, b) => (0..len)
                .map(|i| if at(*c, i) != 0.0 { at(*a, i) } else { at(*b, i) })
                .collect(),
            Op::Cast(a) => (0..len)
                .map(|i| {
                    let x = at(*a, i);
                    match (p.values[*a].ty, v.ty) {
                        (_, Ty::Bool) => {
                            if x != 0.0 {
                                1.0
                            } else {
                                0.0
                            }
                        }
                        (Ty::F32, Ty::I64) => x.trunc(),
                        _ => x,
                    }
                })
                .collect(),
            Op::Reduce(op, a) => {
                let x = &vals[*a];
                let mut acc = x[x.len() - 1];
                for i in (0..x.len() - 1).rev() {
                    acc = match op {
                        RedOp::Add => x[i] + acc,
                        RedOp::Max => x[i].max(acc),
                        RedOp::Min => x[i].min(acc),
                    };
                }
                vec![acc]
            }
        };
        debug_assert!(matches!(v.shape, Shape::Scalar) == (computed.len() == 1) || len == 1);
        if v.ty == Ty::I64 {
            if let Some(x) = computed.iter().find(|x| x.abs() > EXACT_INT) {
                return Err(format!(
                    "%{} holds {x}, beyond 2^24: ints are carried in f32 here and stay exact only below it",
                    v.name
                ));
            }
        }
        vals.push(computed);
    }
    Ok(p.outputs.iter().map(|&o| vals[o].clone()).collect())
}
