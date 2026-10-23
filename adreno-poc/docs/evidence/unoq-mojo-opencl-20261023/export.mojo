@export("mojo_add")
def mojo_add(a: Float32, b: Float32) abi("C") -> Float32:
    return a + b
