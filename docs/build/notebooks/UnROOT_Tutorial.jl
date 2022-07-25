### A Pluto.jl notebook ###
# v0.19.5

using Markdown
using InteractiveUtils

# ╔═╡ e6a8c80c-9751-408a-ac4c-9002a532a9fd
begin
    docs_dir = dirname(dirname(@__DIR__))
    pkg_dir = dirname(docs_dir)
    using Pkg
    Pkg.activate(docs_dir)
    Pkg.instantiate()
end;

# ╔═╡ 8b75225c-b9da-4495-89cb-ff5ecd8c06c2
using UnROOT

# ╔═╡ 2c49d5aa-7a14-4cac-b200-fd36eb830f00
# We have Makie recipe for histograms, implemented in FHist.jl
using FHist, CairoMakie

# ╔═╡ 19b6dac0-ceb5-48cf-9f4b-beda5149e51d
using LaTeXStrings

# ╔═╡ a6ff29b2-e501-4bca-9f5a-3388a8d7a262
md"# Opening a file"

# ╔═╡ 6ef1771e-4ae3-411f-987e-3f8d64b28be4
file = ROOTFile(joinpath(pkg_dir, "unroot-tutorial-file.root"))

# ╔═╡ 4578e85b-98a2-4b09-a0e2-b8d3b12540ad
md"# File contents"

# ╔═╡ 2b5797e9-0eaa-4c69-b653-503377cd6551
keys(file)

# ╔═╡ b06d57c8-893b-4426-8c8a-f5cc9889bc13
typeof(LazyTree(file, "Events"))

# ╔═╡ 10dc43a3-1037-42d9-8626-8a1047f48944
md"# Accessing contents"

# ╔═╡ a175696a-2933-41e1-96b2-5cdf397618f2
tree = LazyTree(file, "Events");

# ╔═╡ 4926de4b-6a59-4456-9e1d-62165f0d50fa
# you can also use `names()` if you want a `Vector{String}`
propertynames(tree)

# ╔═╡ 845d95dc-9b83-45e7-a125-5438796b7868
md"# Branches"

# ╔═╡ d870dfe9-c90e-4970-bac5-f9f82400b5b4
tree.nMuon

# ╔═╡ 48148738-17ec-49ae-8f72-01a733b2e87a
# more DataFrames.jl syntax
tree[:, :Muon_pt]

# ╔═╡ e77aa46e-388b-4e8f-a3ab-b51dc675d9bc
md"# Events"

# ╔═╡ 1422ae67-87d5-4477-a443-a0f3277d1452
tree.Muon_pt[begin] #or [1]

# ╔═╡ 7f0723bc-5b01-420b-929b-3bfa27ad4f91
# more DataFrames.jl syntax
tree[3, :Muon_pt]

# ╔═╡ 1bb15cfc-677b-4308-a9f8-a43fddac9739
tree[1]

# ╔═╡ 69bfa82e-a2c9-49ce-9153-e2757abdbfd8
# to materialize it, don't do this in event loop
Tuple(first(tree))

# ╔═╡ c9f5e90d-1112-48d2-9c4d-69cee420f067
md"# Histogramming basics"

# ╔═╡ fc6dca05-2cae-4be4-b1a3-97868d67e36f
plot(Hist1D(tree.nMuon), figure=(resolution = (400, 300),))

# ╔═╡ 5b05c1f5-296e-4fbb-b1d2-218cd66a24bf
stairs(Hist1D(tree.nMuon, 0:10);
	figure=(resolution = (400, 300), ),
	axis=(xlabel="# of muons in event", ylabel="# of events")
)

# ╔═╡ 8824c90d-c38b-44a4-bb2e-4aa499d69af1
md"# Histogramming a jagged array"

# ╔═╡ 79ee8f58-0db1-4442-aed7-afca9716e443
begin
	h = Hist1D(collect(Iterators.flatten(tree.Muon_pt)), 0:100)
	plot(h;
		figure=(resolution = (400, 300), ),
		axis=(xlabel=L"\mathrm{Muon}~p_{\mathrm{T}}~\mathrm{[GeV]}", ylabel="# of muons / 1 GeV")
	)
end

# ╔═╡ cdb2fe64-a7af-4b3d-b5a0-5239849e5868
md"# Logarithmic scales"

# ╔═╡ 63845f49-9732-4035-ab2b-c06adbf85b55
plot(h;
		figure=(resolution = (400, 300), ),
		axis=(xlabel=L"\mathrm{Muon}~p_{\mathrm{T}}~\mathrm{[GeV]}", 
		ylabel="# of muons / 1 GeV",
		yscale=Makie.pseudolog10, yticks = 10 .^ (1:4)
		)
	)

# ╔═╡ 7bfcefe6-35cc-43df-abe1-9afa34a9b41b
begin
	log_xs = 10 .^ range(log10(1), log10(100); length=100)
	h_logscape = Hist1D(collect(Iterators.flatten(tree.Muon_pt)), log_xs)
	
	stairs(h_logscape;
			figure=(resolution = (400, 300), ),
			axis=(xlabel=L"\mathrm{Muon}~p_{\mathrm{T}}~\mathrm{[GeV]}", 
			ylabel="# of muons / 1 GeV",
			xscale=Makie.pseudolog10,
			xticks=[1,10,100]
			)
		)
end

# ╔═╡ 7db0f6f1-ee13-4e96-8ccd-cb4e986a278f
md"# Coundintg"

# ╔═╡ 4a6006ed-1787-4548-9416-e5ce090fa72d
length(tree), length(tree.nMuon), length(tree.Muon_pt)

# ╔═╡ d9e952c5-d077-4c7d-a902-7882ce3c9759
md"# Selections"

# ╔═╡ 9bb52754-2be2-4c22-a1fa-d85b34117eb5
md"## Selections from 1D arrays"

# ╔═╡ b076613c-3598-4b67-a228-e30497525acb
# allocate a big intermedate array, very pythonic
single_muon_mask = tree.nMuon .== 1

# ╔═╡ eb995f0c-d3ab-4e88-9ca4-3df3068ded8e
md"### Counting with selections"

# ╔═╡ 5ffa29c0-a219-43be-a9f0-70a09b95591c
sum(single_muon_mask)

# ╔═╡ 7c19940c-5369-436c-a265-53bdd2e0d97c
# in Julia, much better to just
# minimal mem allocation -> faster
sum(==(1), tree.nMuon)

# ╔═╡ 9fb1fc42-90cf-4fca-8da5-8224895f0a74
md"### Applying a mask to an array"

# ╔═╡ f29b616a-4292-4cb3-8e3c-3fd3e0710cc9
tree.Muon_pt[single_muon_mask]

# notice, @view should also work
# @view tree.Muon_pt[single_muon_mask]

# ╔═╡ 511a83e7-c6d2-49c5-bd4b-ea110f8cd165
length(tree.Muon_pt[single_muon_mask])

# ╔═╡ e93fe9ed-a658-43b8-a601-afa39ebe6948
md"### Plotting with selections"

# ╔═╡ 14278424-e992-4118-80f7-486efdfdc608
begin
	h_selection = Hist1D(collect(Iterators.flatten(tree.Muon_pt[single_muon_mask])), 0:100)
	plot(h_selection;
			figure=(resolution = (400, 300), ),
			axis=(xlabel=L"\mathrm{Muon}~p_{\mathrm{T}}~\mathrm{[GeV]}", 
			ylabel="# of muons / 1 GeV",
			yscale=Makie.pseudolog10, yticks = 10 .^ (1:4)
			)
		)
end

# ╔═╡ 92fc0757-19b0-4ec5-bad6-a0eab905203c
md"### Selections from a jagged array"

# ╔═╡ 6fbc0e9e-62cd-41d4-8d92-c1d4efc849c1
mapreduce(+, tree.Muon_eta) do etas
	count(eta -> abs(eta)<2, etas)
end

# ╔═╡ Cell order:
# ╟─a6ff29b2-e501-4bca-9f5a-3388a8d7a262
# ╟─e6a8c80c-9751-408a-ac4c-9002a532a9fd
# ╠═8b75225c-b9da-4495-89cb-ff5ecd8c06c2
# ╠═6ef1771e-4ae3-411f-987e-3f8d64b28be4
# ╟─4578e85b-98a2-4b09-a0e2-b8d3b12540ad
# ╠═2b5797e9-0eaa-4c69-b653-503377cd6551
# ╠═b06d57c8-893b-4426-8c8a-f5cc9889bc13
# ╟─10dc43a3-1037-42d9-8626-8a1047f48944
# ╠═a175696a-2933-41e1-96b2-5cdf397618f2
# ╠═4926de4b-6a59-4456-9e1d-62165f0d50fa
# ╟─845d95dc-9b83-45e7-a125-5438796b7868
# ╠═d870dfe9-c90e-4970-bac5-f9f82400b5b4
# ╠═48148738-17ec-49ae-8f72-01a733b2e87a
# ╟─e77aa46e-388b-4e8f-a3ab-b51dc675d9bc
# ╠═1422ae67-87d5-4477-a443-a0f3277d1452
# ╠═7f0723bc-5b01-420b-929b-3bfa27ad4f91
# ╠═1bb15cfc-677b-4308-a9f8-a43fddac9739
# ╠═69bfa82e-a2c9-49ce-9153-e2757abdbfd8
# ╟─c9f5e90d-1112-48d2-9c4d-69cee420f067
# ╠═2c49d5aa-7a14-4cac-b200-fd36eb830f00
# ╠═fc6dca05-2cae-4be4-b1a3-97868d67e36f
# ╠═5b05c1f5-296e-4fbb-b1d2-218cd66a24bf
# ╟─8824c90d-c38b-44a4-bb2e-4aa499d69af1
# ╠═19b6dac0-ceb5-48cf-9f4b-beda5149e51d
# ╠═79ee8f58-0db1-4442-aed7-afca9716e443
# ╟─cdb2fe64-a7af-4b3d-b5a0-5239849e5868
# ╠═63845f49-9732-4035-ab2b-c06adbf85b55
# ╠═7bfcefe6-35cc-43df-abe1-9afa34a9b41b
# ╟─7db0f6f1-ee13-4e96-8ccd-cb4e986a278f
# ╠═4a6006ed-1787-4548-9416-e5ce090fa72d
# ╟─d9e952c5-d077-4c7d-a902-7882ce3c9759
# ╟─9bb52754-2be2-4c22-a1fa-d85b34117eb5
# ╠═b076613c-3598-4b67-a228-e30497525acb
# ╟─eb995f0c-d3ab-4e88-9ca4-3df3068ded8e
# ╠═5ffa29c0-a219-43be-a9f0-70a09b95591c
# ╠═7c19940c-5369-436c-a265-53bdd2e0d97c
# ╟─9fb1fc42-90cf-4fca-8da5-8224895f0a74
# ╠═f29b616a-4292-4cb3-8e3c-3fd3e0710cc9
# ╠═511a83e7-c6d2-49c5-bd4b-ea110f8cd165
# ╟─e93fe9ed-a658-43b8-a601-afa39ebe6948
# ╠═14278424-e992-4118-80f7-486efdfdc608
# ╟─92fc0757-19b0-4ec5-bad6-a0eab905203c
# ╠═6fbc0e9e-62cd-41d4-8d92-c1d4efc849c1
