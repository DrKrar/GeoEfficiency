abstract type GeoException <: Exception end

import Base: showerror

showerror(io::IO, err::GeoException) = print(io, typeof(err), ": ", err.msg)

struct  InValidDetectorDim <: GeoException
	msg::AbstractString
end

"""
    @validateDetector cond [text]

Throw an [`InValidDetectorDim`](@ref) if `cond` is `false`. 
Message `text` is optionally displayed upon validation failure.

# Examples
```jldoctest
julia> @validateDetector iseven(3) "3 is an odd number!"
ERROR: InValidDetectorDim: 3 is an odd number!

julia> @validateDetector isodd(3) "What even are numbers?"
```
"""
macro validateDetector(ex, msgs...)
    msg = isempty(msgs) ? "'$ex' is not satisfied" : msgs[1]
    if isa(msg, AbstractString)
        msg = msg # pass-through

    elseif !isempty(msgs) && (isa(msg, Expr) || isa(msg, Symbol))
        # message is an expression needing evaluating
        msg = :(Main.Base.string($(esc(msg))))

    elseif applicable(Main.Base.string, msg)
        msg = Main.Base.string(msg)

    else
        # string() might not be defined during bootstrap
        msg = :(Main.Base.string($(Expr(:quote,msg))))

    end
    return :($(esc(ex)) ? $(nothing) : throw(InValidDetectorDim($msg)))
end

struct  NotImplementedError <: GeoException
	msg::AbstractString
end

macro notImplementedError(msgs...)
    msg = isempty(msgs) ? "" : msgs[1]
    if isa(msg, AbstractString)
        msg = msg # pass-through
    elseif !isempty(msgs) && (isa(msg, Expr) || isa(msg, Symbol))
        # message is an expression needing evaluating
        msg = :(Main.Base.string($(esc(msg))))
    else
        # string() might not be defined during bootstrap
        msg = :(Main.Base.string(msg))
    end
    return :(throw(NotImplementedError($msg)))
end