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
begin
	using LaTeXStrings
	using Base.Iterators: flatten #stdlib, save some typing
end

# ╔═╡ 22c83079-6155-4991-8ec8-007d67d9142d
using BenchmarkTools

# ╔═╡ 66b10dce-552a-4129-8cc3-1ce4c543e8b5
using LorentzVectorHEP

# ╔═╡ a6ff29b2-e501-4bca-9f5a-3388a8d7a262
md"## Opening Files"

# ╔═╡ 6ef1771e-4ae3-411f-987e-3f8d64b28be4
file = ROOTFile(joinpath(pkg_dir, "unroot-tutorial-file.root"))

# ╔═╡ 4578e85b-98a2-4b09-a0e2-b8d3b12540ad
md"### File contents"

# ╔═╡ 2b5797e9-0eaa-4c69-b653-503377cd6551
keys(file)

# ╔═╡ b06d57c8-893b-4426-8c8a-f5cc9889bc13
typeof(LazyTree(file, "Events"))

# ╔═╡ 10dc43a3-1037-42d9-8626-8a1047f48944
md"### Accessing contents"

# ╔═╡ a175696a-2933-41e1-96b2-5cdf397618f2
tree = LazyTree(file, "Events");

# ╔═╡ 4926de4b-6a59-4456-9e1d-62165f0d50fa
# you can also use `names()` if you want a `Vector{String}`
propertynames(tree)

# ╔═╡ 845d95dc-9b83-45e7-a125-5438796b7868
md"## Trees, Branches, and Events
"

# ╔═╡ d870dfe9-c90e-4970-bac5-f9f82400b5b4
tree.nMuon

# ╔═╡ 48148738-17ec-49ae-8f72-01a733b2e87a
# more DataFrames.jl syntax
tree[:, :Muon_pt]

# ╔═╡ e77aa46e-388b-4e8f-a3ab-b51dc675d9bc
md"### Events"

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
md"## Histograms"

# ╔═╡ fc6dca05-2cae-4be4-b1a3-97868d67e36f
plot(Hist1D(tree.nMuon), figure=(resolution = (400, 300),))

# ╔═╡ 5b05c1f5-296e-4fbb-b1d2-218cd66a24bf
stairs(Hist1D(tree.nMuon, 0:10);
	figure=(resolution = (400, 300), ),
	axis=(xlabel="# of muons in event", ylabel="# of events")
)

# ╔═╡ 8824c90d-c38b-44a4-bb2e-4aa499d69af1
md"### Histogramming a jagged array"

# ╔═╡ 79ee8f58-0db1-4442-aed7-afca9716e443
begin
	h = Hist1D(flatten(tree.Muon_pt), 0:100)
	plot(h;
		figure=(resolution = (400, 300), ),
		axis=(xlabel=L"\mathrm{Muon}~p_{\mathrm{T}}~\mathrm{[GeV]}", ylabel="# of muons / 1 GeV")
	)
end

# ╔═╡ cdb2fe64-a7af-4b3d-b5a0-5239849e5868
md"### Logarithmic scales"

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
	h_logscape = Hist1D(flatten(tree.Muon_pt), log_xs)
	
	stairs(h_logscape;
			figure=(resolution = (400, 300), ),
			axis=(xlabel=L"\mathrm{Muon}~p_{\mathrm{T}}~\mathrm{[GeV]}", 
			ylabel="# of muons / 1 GeV",
			xscale=Makie.pseudolog10,
			xticks=[1,10,100]
			)
	)
end

# ╔═╡ 93e47f55-4726-46db-b14d-543912ca276f
md"## Columnar? Row-based? both!"

# ╔═╡ 7db0f6f1-ee13-4e96-8ccd-cb4e986a278f
md"### Counting"

# ╔═╡ 4a6006ed-1787-4548-9416-e5ce090fa72d
length(tree), length(tree.nMuon), length(tree.Muon_pt)

# ╔═╡ d9e952c5-d077-4c7d-a902-7882ce3c9759
md"""### Selections

!!! warning "Vectorized style can be traps"
	Vectorized style is a somewhat emphasized point in Python programming especially if one wants performance. However, `numpy.sum()` is nothing more than a loop written in C.

	Since Julia is not slow, from now on, we deviate from uproot tutorial in that we are allowed to use for-loop whenever appropriate which has several benefits:
	- More expressive
	- Less memory allocation
"""

# ╔═╡ 9bb52754-2be2-4c22-a1fa-d85b34117eb5
md"### Selections from 1D arrays"

# ╔═╡ b076613c-3598-4b67-a228-e30497525acb
# allocate a big intermedate array, not very Julia
single_muon_mask = tree.nMuon .== 1

# ╔═╡ eb995f0c-d3ab-4e88-9ca4-3df3068ded8e
md"### Counting with selections (uproot way)"

# ╔═╡ 5ffa29c0-a219-43be-a9f0-70a09b95591c
sum(single_muon_mask)

# ╔═╡ 9fb1fc42-90cf-4fca-8da5-8224895f0a74
md"""### Applying a mask to an array

!!! info
	Just because you can doesn't mean you should, I can't think of a good reason
	to do this kind of mask and allocation other than pedagogy.
"""

# ╔═╡ f29b616a-4292-4cb3-8e3c-3fd3e0710cc9
tree.Muon_pt[single_muon_mask]

# notice, @view should also work

# ╔═╡ 511a83e7-c6d2-49c5-bd4b-ea110f8cd165
length(tree.Muon_pt[single_muon_mask])

# ╔═╡ 77a8f701-5ea5-4a65-b4e1-4e39c915560c
md"### Counting with selections (Julia way)"

# ╔═╡ 7c19940c-5369-436c-a265-53bdd2e0d97c
# minimal mem allocation -> faster
sum(==(1), tree.nMuon)

# ╔═╡ e93fe9ed-a658-43b8-a601-afa39ebe6948
md"### Plotting with selections"

# ╔═╡ 14278424-e992-4118-80f7-486efdfdc608
begin
	h_selection = Hist1D(flatten(tree.Muon_pt[single_muon_mask]), 0:100)
	plot(h_selection;
			figure=(resolution = (400, 300), ),
			axis=(xlabel=L"\mathrm{Muon}~p_{\mathrm{T}}~\mathrm{[GeV]}", 
			ylabel="# of muons / 1 GeV",
			yscale=Makie.pseudolog10, yticks = 10 .^ (1:4)
			)
	)
end

# ╔═╡ 92fc0757-19b0-4ec5-bad6-a0eab905203c
md"## Selections from a jagged array the Julia way"

# ╔═╡ 6fbc0e9e-62cd-41d4-8d92-c1d4efc849c1
mapreduce(+, tree.Muon_eta) do etas
	count(x -> -2 < x < 2, etas)
end

# ╔═╡ 1c238044-1a65-4f89-955d-ffc439eca23e
with_theme(ATLASTHEME) do 
	bins = range(-2.5, 2.5; length=51)
	# Set up
	fig = Figure(; resolution = (500, 700))
	h_eta = Hist1D(; bins) # shot-hand for `Hist1D(; bins=bins)`
	h_eta_sel = Hist1D(; bins)

	for η in flatten(tree.Muon_eta)
		push!(h_eta, η) # always fill upper histogran
		abs(η) >= 2 && continue
		push!(h_eta_sel, η) # fill lower histogram
	end

	# Plot upper axis
	plot(fig[1,1], h_eta;
			axis=(
				title="No selection", 
				xlabel=L"\mathrm{Muon}~\eta",
				ylabel="# of muons",
			)
		)
	# Plot lower axis
	plot(fig[2,1], h_eta_sel;
			axis=(
				title="With |η| < 2 selection", 
				xlabel=L"\mathrm{Muon}~\eta",
				ylabel="# of muons",
			)
		)
	fig
end

# ╔═╡ 3aa7b6a5-1239-4591-85d6-4b5af5b62f02
md"## Comparing histograms"

# ╔═╡ d138ae76-9d55-4adb-a551-db649ab19c09
begin
		h_pt1 = Hist1D(; bins = 0:2:50)
		h_pt2 = Hist1D(; bins = 0:2:50)
		for evt in tree
			(; nMuon, Muon_pt, Muon_eta) = evt
			nMuon != 1 && continue # single_muon_mask
			eta_mask = @. abs(Muon_eta) < 2
			push!.(h_pt1, Muon_pt[eta_mask])
			push!.(h_pt2, Muon_pt[(~).(eta_mask)])
		end
		
end

# ╔═╡ 6ac418c3-3a0e-4973-b762-51b9c76db0b6
with_theme(ATLASTHEME) do
	stairs(
		h_pt1; label = L"|\eta|~<~2",
		figure = (; resolution = (500, 400)),
		axis = (ylabel = "Number of single muons / 2 GeV",)
	)
	stairs!(h_pt2; label = L"|\eta|~\geq~2")

	axislegend()
	current_figure()
end

# ╔═╡ 8d563e0f-b45f-4d61-b380-44ac0b3edf60
with_theme(ATLASTHEME) do
	stairs(
		normalize(h_pt1); label = L"|\eta|~<~2",
		figure = (; resolution = (500, 400)),
		axis = (title="Normalized", ylabel = "Number of single muons / 2 GeV")
	)
	stairs!(normalize(h_pt2); label = L"|\eta|~\geq~2")

	axislegend()
	current_figure()
end

# ╔═╡ 9b663bb1-67c9-4b29-ad2d-aca2331cd4dd
md"""
!!! tip "Columnar vs. row-based analysis"
	We want to emphasize again the fact that Julia doesn't slow down when doing row-based analysis, and we find the flexibility and scalability appealing.

	We cite some timing from uproot python tutorial for comparison:

Python row-based:
```python
CPU times: user 4.78 s, sys: 77.2 ms, total: 4.86 s
Wall time: 4.88 s
```
Python columnar:
```python
CPU times: user 5.18 ms, sys: 1 ms, total: 6.18 ms
Wall time: 4.87 ms
```

With Julia, we can easily find situation where row-based is **faster** than columnar:
"""

# ╔═╡ 788bbeb8-c61b-41ea-b904-41f80d5d264a
@benchmark mapreduce(+, $tree.Muon_eta) do etas
	count(x -> -2 < x < 2, etas)
end

# ╔═╡ cbab9f62-672c-439e-bdad-ffb0aa1399f0
md"## Getting Physics-Relevant Information"

# ╔═╡ 404cf7b3-41cb-4bcd-b7a4-b35e9cd414a6
begin 
	hist_ΔR = Hist1D(; bins = 0:0.05:6)
	for evt in tree
		evt.nMuon != 2 && continue #two_muons_mask
		(; Muon_pt, Muon_eta, Muon_phi, Muon_mass) = evt
		two_muons_p4 = LorentzVectorCyl.(Muon_pt, Muon_eta, Muon_phi, Muon_mass)
		# we know:
		# two_muons_p4::Vector{LorentzVectorCyl} and its length == 2

		push!(hist_ΔR, deltar(two_muons_p4...))
	end
	plot(hist_ΔR; 
		figure = (; resolution = (500, 400)),
		axis = (xlabel = "ΔR between muons", ylabel = "Number of two-muon events")
	)
end

# ╔═╡ 90f38d7f-23cf-4c1e-986f-90b7c78d6de4
md"### Opposite sign muons"

# ╔═╡ 05123d1c-eb9f-46ee-b620-21d3ca9733d6
with_theme(ATLASTHEME) do
	log_bins = 10 .^ range(log10(0.1), log10(1000); length=200)
	hist_inv = Hist1D(; bins = log_bins)
	for evt in tree
		evt.nMuon != 2 && continue #two_muons_mask
		(; Muon_charge) = evt
		Muon_charge[1] == Muon_charge[2] && continue # require oppo sign
		(; Muon_pt, Muon_eta, Muon_phi, Muon_mass) = evt
		two_muons_p4 = LorentzVectorCyl.(Muon_pt, Muon_eta, Muon_phi, Muon_mass)
		# we know:
		# two_muons_p4::Vector{LorentzVectorCyl} and its length == 2

		push!(hist_inv, mass(sum(two_muons_p4)))
	end
	stairs(hist_inv; 
		figure = (; resolution = (600, 400)),
		axis = (xlabel = "Dimuon invariant mass [GeV]",
		xscale = Makie.pseudolog10,
		xticks = [0.1, 1, 10, 100, 1000],
		yscale = Makie.pseudolog10,
		yticks = [1, 10, 100, 1000],
		ylabel = "Number of dimuon events")
	)
	# text annotation
	ps = Dict("Z"=>91.2, "J/Ψ"=>3.09, "Υ"=>9.4, "Ψ(2S)"=>3.686, "ϕ"=>1.019, "ρ"=>0.775, "η"=>0.52)
	for (k,v) in ps
		text!(v, lookup(hist_inv, v); text = k, align = (:center, :baseline))
	end

	current_figure()
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
# ╟─63845f49-9732-4035-ab2b-c06adbf85b55
# ╠═7bfcefe6-35cc-43df-abe1-9afa34a9b41b
# ╟─93e47f55-4726-46db-b14d-543912ca276f
# ╟─7db0f6f1-ee13-4e96-8ccd-cb4e986a278f
# ╠═4a6006ed-1787-4548-9416-e5ce090fa72d
# ╟─d9e952c5-d077-4c7d-a902-7882ce3c9759
# ╟─9bb52754-2be2-4c22-a1fa-d85b34117eb5
# ╠═b076613c-3598-4b67-a228-e30497525acb
# ╟─eb995f0c-d3ab-4e88-9ca4-3df3068ded8e
# ╠═5ffa29c0-a219-43be-a9f0-70a09b95591c
# ╟─9fb1fc42-90cf-4fca-8da5-8224895f0a74
# ╠═f29b616a-4292-4cb3-8e3c-3fd3e0710cc9
# ╠═511a83e7-c6d2-49c5-bd4b-ea110f8cd165
# ╟─77a8f701-5ea5-4a65-b4e1-4e39c915560c
# ╠═7c19940c-5369-436c-a265-53bdd2e0d97c
# ╟─e93fe9ed-a658-43b8-a601-afa39ebe6948
# ╠═14278424-e992-4118-80f7-486efdfdc608
# ╟─92fc0757-19b0-4ec5-bad6-a0eab905203c
# ╠═6fbc0e9e-62cd-41d4-8d92-c1d4efc849c1
# ╠═1c238044-1a65-4f89-955d-ffc439eca23e
# ╟─3aa7b6a5-1239-4591-85d6-4b5af5b62f02
# ╠═d138ae76-9d55-4adb-a551-db649ab19c09
# ╠═6ac418c3-3a0e-4973-b762-51b9c76db0b6
# ╠═8d563e0f-b45f-4d61-b380-44ac0b3edf60
# ╟─9b663bb1-67c9-4b29-ad2d-aca2331cd4dd
# ╠═22c83079-6155-4991-8ec8-007d67d9142d
# ╠═788bbeb8-c61b-41ea-b904-41f80d5d264a
# ╟─cbab9f62-672c-439e-bdad-ffb0aa1399f0
# ╠═66b10dce-552a-4129-8cc3-1ce4c543e8b5
# ╠═404cf7b3-41cb-4bcd-b7a4-b35e9cd414a6
# ╟─90f38d7f-23cf-4c1e-986f-90b7c78d6de4
# ╠═05123d1c-eb9f-46ee-b620-21d3ca9733d6
