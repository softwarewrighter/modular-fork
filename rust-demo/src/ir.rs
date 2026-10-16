//! A tiny accelerator IR: the subset of X_eTaL-gpu's XIR that this demo
//! lowers to Mojo. Typed values of one scalar type (f32, i64 or bool) and one
//! of two shapes (a single value, or a vector of the program's length N);
//! elementwise maps with scalar extension, a select by mask, a cast, and
//! whole-array reductions. The text form is XIR's, so a program here reads
//! the same as one in X_eTaL-gpu's `components/xir`, and what `xetal-gpu
//! lower` writes for an X_eTaL program in the subset is read as is.
//!
//! Ints are a shortcut here: an i64 value is carried in f32 on the device
//! and in the reference, which is exact while every item stays below 2^24
//! (the checker and the reference refuse larger ones). A real int path is
//! X_eTaL-gpu's saga gpu-mojo, step 2.

use std::collections::HashMap;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Ty {
    F32,
    I64,
    Bool,
}

/// The largest magnitude an i64 item may have here: f32 carries integers
/// exactly up to 2^24.
pub const EXACT_INT: f32 = 16_777_216.0;

impl Ty {
    pub fn name(self) -> &'static str {
        match self {
            Ty::F32 => "f32",
            Ty::I64 => "i64",
            Ty::Bool => "bool",
        }
    }
    pub fn is_number(self) -> bool {
        self != Ty::Bool
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Shape {
    Scalar,
    Vector(usize),
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum MapOp {
    Add,
    Sub,
    Mul,
    Div,
    Mod,
    Min,
    Max,
    Neg,
    Abs,
    Exp,
    Log,
    Eq,
    Ne,
    Lt,
    Le,
    Gt,
    Ge,
    And,
    Or,
    Not,
}

impl MapOp {
    pub fn parse(s: &str) -> Option<MapOp> {
        use MapOp::*;
        Some(match s {
            "add" => Add,
            "sub" => Sub,
            "mul" => Mul,
            "div" => Div,
            "mod" => Mod,
            "min" => Min,
            "max" => Max,
            "neg" => Neg,
            "abs" => Abs,
            "exp" => Exp,
            "log" => Log,
            "eq" => Eq,
            "ne" => Ne,
            "lt" => Lt,
            "le" => Le,
            "gt" => Gt,
            "ge" => Ge,
            "and" => And,
            "or" => Or,
            "not" => Not,
            _ => return None,
        })
    }

    pub fn name(self) -> &'static str {
        use MapOp::*;
        match self {
            Add => "add",
            Sub => "sub",
            Mul => "mul",
            Div => "div",
            Mod => "mod",
            Min => "min",
            Max => "max",
            Neg => "neg",
            Abs => "abs",
            Exp => "exp",
            Log => "log",
            Eq => "eq",
            Ne => "ne",
            Lt => "lt",
            Le => "le",
            Gt => "gt",
            Ge => "ge",
            And => "and",
            Or => "or",
            Not => "not",
        }
    }

    pub fn arity(self) -> usize {
        use MapOp::*;
        match self {
            Neg | Abs | Exp | Log | Not => 1,
            _ => 2,
        }
    }

    /// The result type for arguments of type `arg`, or why the op refuses them.
    pub fn result_ty(self, arg: Ty) -> Result<Ty, String> {
        use MapOp::*;
        match self {
            Add | Sub | Mul | Mod | Min | Max | Neg | Abs => {
                if arg.is_number() {
                    Ok(arg)
                } else {
                    Err(format!("`{}` takes numbers, not bools", self.name()))
                }
            }
            Div | Exp | Log => {
                if arg == Ty::F32 {
                    Ok(Ty::F32)
                } else {
                    Err(format!("`{}` takes f32 (X_eTaL's `/` makes Floats; ints take `cast`)", self.name()))
                }
            }
            Eq | Ne => Ok(Ty::Bool),
            Lt | Le | Gt | Ge => {
                if arg.is_number() {
                    Ok(Ty::Bool)
                } else {
                    Err(format!("`{}` compares numbers, not bools", self.name()))
                }
            }
            And | Or | Not => {
                if arg == Ty::Bool {
                    Ok(Ty::Bool)
                } else {
                    Err(format!("`{}` takes bools, not numbers", self.name()))
                }
            }
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum RedOp {
    Add,
    Max,
    Min,
}

impl RedOp {
    pub fn parse(s: &str) -> Option<RedOp> {
        Some(match s {
            "add" => RedOp::Add,
            "max" => RedOp::Max,
            "min" => RedOp::Min,
            _ => return None,
        })
    }
    pub fn name(self) -> &'static str {
        match self {
            RedOp::Add => "add",
            RedOp::Max => "max",
            RedOp::Min => "min",
        }
    }
}

#[derive(Clone, Debug)]
pub enum Op {
    Input,
    Const(Vec<f32>),
    Map(MapOp, Vec<usize>),
    Select(usize, usize, usize),
    /// `cast TY %x`: the value's type to this one, item by item.
    Cast(usize),
    Reduce(RedOp, usize),
}

#[derive(Clone, Debug)]
pub struct Value {
    pub name: String,
    pub ty: Ty,
    pub shape: Shape,
    pub op: Op,
}

impl Value {
    pub fn len(&self) -> usize {
        match self.shape {
            Shape::Scalar => 1,
            Shape::Vector(n) => n,
        }
    }
    pub fn is_vector(&self) -> bool {
        matches!(self.shape, Shape::Vector(_))
    }
}

#[derive(Clone, Debug)]
pub struct Program {
    pub values: Vec<Value>,
    pub outputs: Vec<usize>,
    /// The vector length every vector in the program shares (1 when there is none).
    pub n: usize,
}

impl Program {
    pub fn inputs(&self) -> Vec<usize> {
        (0..self.values.len())
            .filter(|&i| matches!(self.values[i].op, Op::Input))
            .collect()
    }
    pub fn index_of(&self, name: &str) -> Option<usize> {
        self.values.iter().position(|v| v.name == name)
    }
}

fn parse_ty(s: &str, line: usize) -> Result<Ty, String> {
    match s {
        "f32" | "f64" => Ok(Ty::F32),
        "i64" | "i32" => Ok(Ty::I64),
        "bool" => Ok(Ty::Bool),
        other => Err(format!(
            "line {line}: unknown scalar type `{other}` (f32, f64 as f32, i64 carried in f32, or bool)"
        )),
    }
}

/// Parses a shape written as `[]`, `[8]` or `[ 8 ]`; consumes tokens up to the `]`.
fn parse_shape(tokens: &[&str], line: usize) -> Result<(Shape, usize), String> {
    let mut used = 0;
    let mut text = String::new();
    for t in tokens {
        used += 1;
        text.push_str(t);
        if t.ends_with(']') {
            break;
        }
    }
    if !text.starts_with('[') || !text.ends_with(']') {
        return Err(format!("line {line}: a shape is written [] or [n], not `{text}`"));
    }
    let inner = text[1..text.len() - 1].trim();
    if inner.is_empty() {
        return Ok((Shape::Scalar, used));
    }
    if inner.contains(' ') {
        return Err(format!(
            "line {line}: only rank 0 and rank 1 shapes here, not `{text}`"
        ));
    }
    let n: usize = inner
        .parse()
        .map_err(|_| format!("line {line}: bad length in shape `{text}`"))?;
    if n == 0 {
        return Err(format!("line {line}: an empty vector has nothing to compute"));
    }
    Ok((Shape::Vector(n), used))
}

fn note_len(n: &mut Option<usize>, shape: Shape, line: usize) -> Result<(), String> {
    if let Shape::Vector(k) = shape {
        match *n {
            None => *n = Some(k),
            Some(m) if m != k => {
                return Err(format!(
                    "line {line}: every vector shares one length here; [{k}] after [{m}]"
                ))
            }
            _ => {}
        }
    }
    Ok(())
}

pub fn parse(src: &str) -> Result<Program, String> {
    let mut values: Vec<Value> = Vec::new();
    let mut outputs: Vec<usize> = Vec::new();
    let mut by_name: HashMap<String, usize> = HashMap::new();
    let mut n: Option<usize> = None;

    for (i, raw) in src.lines().enumerate() {
        let line = i + 1;
        let text = match raw.find('#') {
            Some(p) => &raw[..p],
            None => raw,
        };
        let tokens: Vec<&str> = text.split_whitespace().collect();
        if tokens.is_empty() {
            continue;
        }
        let arg = |t: &str| -> Result<usize, String> {
            let name = t
                .strip_prefix('%')
                .ok_or_else(|| format!("line {line}: a value is named %name, not `{t}`"))?;
            by_name
                .get(name)
                .copied()
                .ok_or_else(|| format!("line {line}: `%{name}` is not defined yet"))
        };
        if tokens[0] == "output" {
            if tokens.len() != 2 {
                return Err(format!("line {line}: `output %name`"));
            }
            outputs.push(arg(tokens[1])?);
            continue;
        }
        if tokens.len() < 3 || tokens[1] != "=" {
            return Err(format!("line {line}: expected `%name = ...` or `output %name`"));
        }
        let name = tokens[0]
            .strip_prefix('%')
            .ok_or_else(|| format!("line {line}: a value is named %name"))?
            .to_string();
        if by_name.contains_key(&name) {
            return Err(format!("line {line}: `%{name}` is defined twice"));
        }
        if !name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') || name.is_empty() {
            return Err(format!(
                "line {line}: a name is letters, digits and underscores (it becomes a Mojo name)"
            ));
        }
        let rest = &tokens[2..];
        let value = match rest[0] {
            "input" => {
                if rest.len() < 3 {
                    return Err(format!("line {line}: `%x = input f32 [n]`"));
                }
                let ty = parse_ty(rest[1], line)?;
                if ty == Ty::Bool {
                    return Err(format!("line {line}: inputs are numbers (bools come from comparisons)"));
                }
                let (shape, _) = parse_shape(&rest[2..], line)?;
                note_len(&mut n, shape, line)?;
                Value { name, ty, shape, op: Op::Input }
            }
            "const" => {
                if rest.len() < 4 {
                    return Err(format!("line {line}: `%k = const f32 [] 2.0`"));
                }
                let ty = parse_ty(rest[1], line)?;
                let (shape, used) = parse_shape(&rest[2..], line)?;
                note_len(&mut n, shape, line)?;
                let items: Result<Vec<f32>, String> = rest[2 + used..]
                    .iter()
                    .map(|t| {
                        let v: f32 = match ty {
                            Ty::I64 => {
                                let k: i64 = t
                                    .parse()
                                    .map_err(|_| format!("line {line}: `{t}` is not an integer"))?;
                                if k.unsigned_abs() > EXACT_INT as u64 {
                                    return Err(format!(
                                        "line {line}: `{t}` is beyond 2^24; ints are carried in f32 here"
                                    ));
                                }
                                k as f32
                            }
                            _ => t.parse().map_err(|_| format!("line {line}: `{t}` is not a number"))?,
                        };
                        if ty == Ty::Bool && v != 0.0 && v != 1.0 {
                            return Err(format!("line {line}: a bool const is 0 or 1"));
                        }
                        Ok(v)
                    })
                    .collect();
                let items = items?;
                let len = match shape {
                    Shape::Scalar => 1,
                    Shape::Vector(k) => k,
                };
                if items.is_empty() || (items.len() != 1 && items.len() != len) {
                    return Err(format!(
                        "line {line}: a const has one item for all, or one per element ({len})"
                    ));
                }
                Value { name, ty, shape, op: Op::Const(items) }
            }
            "map" => {
                if rest.len() < 3 {
                    return Err(format!("line {line}: `%y = map OP %a [%b]`"));
                }
                let op = MapOp::parse(rest[1])
                    .ok_or_else(|| format!("line {line}: unknown map op `{}`", rest[1]))?;
                let args: Result<Vec<usize>, String> = rest[2..].iter().map(|t| arg(t)).collect();
                let args = args?;
                if args.len() != op.arity() {
                    return Err(format!(
                        "line {line}: `{}` takes {} argument(s), given {}",
                        op.name(),
                        op.arity(),
                        args.len()
                    ));
                }
                let t0 = values[args[0]].ty;
                if args.iter().any(|&a| values[a].ty != t0) {
                    return Err(format!("line {line}: a map's arguments share one type"));
                }
                let ty = op.result_ty(t0).map_err(|e| format!("line {line}: {e}"))?;
                let shape = if args.iter().any(|&a| values[a].is_vector()) {
                    Shape::Vector(n.unwrap())
                } else {
                    Shape::Scalar
                };
                Value { name, ty, shape, op: Op::Map(op, args) }
            }
            "select" => {
                if rest.len() != 4 {
                    return Err(format!("line {line}: `%z = select %cond %a %b`"));
                }
                let (c, a, b) = (arg(rest[1])?, arg(rest[2])?, arg(rest[3])?);
                if values[c].ty != Ty::Bool {
                    return Err(format!("line {line}: select's condition is a bool"));
                }
                if values[a].ty != values[b].ty {
                    return Err(format!("line {line}: select's branches share one type"));
                }
                let shape = if [c, a, b].iter().any(|&v| values[v].is_vector()) {
                    Shape::Vector(n.unwrap())
                } else {
                    Shape::Scalar
                };
                Value { name, ty: values[a].ty, shape, op: Op::Select(c, a, b) }
            }
            "cast" => {
                if rest.len() != 3 {
                    return Err(format!("line {line}: `%y = cast f64 %x`"));
                }
                let ty = parse_ty(rest[1], line)?;
                let a = arg(rest[2])?;
                Value { name, ty, shape: values[a].shape, op: Op::Cast(a) }
            }
            "reduce" => {
                if rest.len() != 3 {
                    return Err(format!("line {line}: `%s = reduce add %x` (whole array only here; no axis)"));
                }
                let op = RedOp::parse(rest[1])
                    .ok_or_else(|| format!("line {line}: unknown reduce op `{}`", rest[1]))?;
                let a = arg(rest[2])?;
                if !values[a].ty.is_number() || !values[a].is_vector() {
                    return Err(format!("line {line}: reduce takes a vector of numbers"));
                }
                Value { name, ty: values[a].ty, shape: Shape::Scalar, op: Op::Reduce(op, a) }
            }
            other => return Err(format!("line {line}: unknown statement `{other}`")),
        };
        by_name.insert(value.name.clone(), values.len());
        values.push(value);
    }
    if outputs.is_empty() {
        return Err("the program has no `output` line".to_string());
    }
    Ok(Program { values, outputs, n: n.unwrap_or(1) })
}
