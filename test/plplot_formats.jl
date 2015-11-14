using Weave
using Base.Test

cleanup = true

weave("documents/plplot_formats.txt", plotlib="PLplot", doctype="tex")
result = readall(open("documents/plplot_formats.tex"))
ref = readall(open("documents/plplot_formats_ref.tex"))
@test result == ref

weave("documents/plplot_formats.txt", plotlib="PLplot", doctype="github")
result = readall(open("documents/plplot_formats.md"))
ref = readall(open("documents/plplot_formats_ref.md"))
@test result == ref

weave("documents/plplot_formats.txt", plotlib="PLplot", doctype="pandoc", fig_ext=".svg")
result = readall(open("documents/plplot_formats.md"))
ref = readall(open("documents/plplot_formats_svg_ref.md"))
@test result == ref

weave("documents/plplot_formats.txt", plotlib="PLplot", doctype="rst")
result = readall(open("documents/plplot_formats.rst"))
ref = readall(open("documents/plplot_formats_ref.rst"))
@test result == ref

if cleanup
    rm("documents/plplot_formats.tex")
    rm("documents/plplot_formats.rst")
    rm("documents/plplot_formats.md")
    rm("documents/figures", recursive = true)
end
