using Plots
using Colors
using LaTeXStrings

function newton_solver(x₀::T, f::Function, f_prime::Function, ϵ::T) where {T <: Number}

    count::UInt128 = 0;

    xₙ::T = x₀;
    x_steps = [x₀];
    y_steps = [f(x₀)];

    while abs.(f(xₙ)) >= abs.(ϵ);

        xₙ = xₙ - f(xₙ)/f_prime(xₙ); #Actualiza xₙ

        push!(x_steps, xₙ) #Inserta el nuevo valor de xₙ en un array para graficarlo
        push!(y_steps, f(xₙ))  #Inserta el nuevo valor de f(xₙ) en un array para graficarlo

        count += 1;

    end

    println("Root of function $f approximated with a precision of $ϵ after $count iteration(s)")

    return (xₙ, x_steps, y_steps);

end

f(x) = x^2 - 2;
f_prime(x) = 2x;
f₀(x) = 0;

println("√2 = ",newton_solver(2.0, f, f_prime, 10e-9)[1]);

const a = 3;
const b = 7;
const x₀ = 1e-3;


f(x) = x^b - cos(a*x);
f_prime(x) = b*x^(b-1) + a*sin(a*x);

x, x_vec, y_vec = newton_solver(1e-3,f, f_prime, 10e-8);

pl = scatter(x_vec, y_vec, 
    color = colormap("Blues",length(x_vec)),
    label = false,
    background = :gray,
    xaxis = L"x",
    yaxis = L"f(x)");

xlims!(minimum(x_vec) - 0.5, maximum(x_vec) + 0.5)

plot!(f, 
    label = L"f(x) = x^%$b - cos(%$a x)",
    color = :red);

plot!(f₀, 
    label = false, 
    color = :blue);

vline!([x], 
    label = L"\hat x = %$x",
    color = :purple)

title!(L"\mathrm{Aproximación\ por\ el\ método\ de\ Newton\ de\ }"
    * "\n" * L"f(x) = x^%$b - cos(%$a x) \mathrm{con\ } x_0 = %$x₀");

savefig(pl, "AdvancedMath/NewtonMethod.png")