using MTCGP
import RDatasets
import Darwin

cfg = get_config("cfg/iris.yaml")

function data_setup()
    iris = RDatasets.dataset("datasets", "iris")
    X = convert(Matrix, iris[:, 1:4])'
    X = X ./ maximum(X; dims=2)
    r = iris[:, 5].refs
    Y = zeros(maximum(r), size(X, 2))
    for i in 1:length(r)
        Y[r[i], i] = 1.0
    end
    X, Y
end

X, Y = data_setup()

e = Darwin.Evolution(MTCGPInd, cfg; id="iris")
mutation = i::MTCGPInd->goldman_mutate(cfg, i)
e.populate = x::Darwin.Evolution->Darwin.oneplus_populate!(
    x; mutation=mutation)
e.evaluate = x::Darwin.Evolution->Darwin.lexicase_evaluate!(
    x, X, Y, MTCGP.interpret)

Darwin.run!(e)
best = sort(e.population)[end]
println("Final fitness: ", best.fitness[1])
