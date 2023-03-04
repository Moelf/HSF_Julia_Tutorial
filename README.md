## Introduction

- This is a Julia counterpart to the [uproot tutorial](https://masonproffitt.github.io/uproot-tutorial/)
- you can access the pre-rendered notebook: https://moelf.github.io/HSF_Julia_Tutorial/ 

## For evelopers:

1. `git clone https://github.com/Moelf/HSF_Julia_Tutorial/`
2. `cd HSF_Julia_Tutorial/docs`
3. `julia --project=.`

then:
```julia
julia> using Pkg

julia> Pkg.instantiate()

julia> using Pluto; Pluto.run()
```

Then using the web GUI, open up notebooks under
```
HSF_Julia_Tutorial/docs/src/notebooks/
```

and start modifying!
