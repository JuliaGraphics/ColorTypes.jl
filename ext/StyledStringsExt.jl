module StyledStringsExt

using ColorTypes
import StyledStrings: SimpleColor

function Base.convert(::Type{SimpleColor}, c::Colorant)
    rgb = convert(RGB24, c)
    r = reinterpret(red(rgb))
    g = reinterpret(green(rgb))
    b = reinterpret(blue(rgb))
    SimpleColor((; r, g, b))
end

end
