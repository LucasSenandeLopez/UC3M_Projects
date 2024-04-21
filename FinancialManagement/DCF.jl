module DCF

export dcf_model, noisy_dcf_model;

function dcf_model(aftertax_ebit_vector::Vector{Float64}, capex_vector::Vector{Float64},
    amortization_depreciation_vector::Vector{Float64}, 
    change_nwc_vector::Vector{Float64}, wacc::Float64, terminal_growth_rate::Float64)::Float64 


    len::UInt32 = length(aftertax_ebit_vector);
    dcfₜ::Float64 = 0.0;
    valuation::Float64 = 0.0;

    length_parity::Bool = (len == length(capex_vector) && len == length(amortization_depreciation_vector)
        && len == length(change_nwc_vector));

    @assert length_parity "All the vectors must be the same length";
    @assert wacc > terminal_growth_rate "The growth rate must be lower than the WACC";


    # Computes discounted cash flows at period t and adds them
    # DCFₜ = (EBITₜ(1- τ₍c₎) + D&Aₜ   - Chang_in_NWCₜ - CAPEXₜ) / (1 + r₍w₎)^t
    @inbounds for t in 1:len 

        dcfₜ = (aftertax_ebit_vector[t] + amortization_depreciation_vector[t] - capex_vector[t]  
        - change_nwc_vector[t]) / (1 + wacc)^t;
            
        valuation += dcfₜ;


    end

       
    # Adds long term growth as an annuity
    valuation += dcfₜ * (1 + terminal_growth_rate) / (wacc - terminal_growth_rate);

    return valuation;

end

function noisy_dcf_model(aftertax_ebit_vector::Vector{Float64}, capex_vector::Vector{Float64},
    amortization_depreciation_vector::Vector{Float64}, 
    change_nwc_vector::Vector{Float64}, wacc::Float64, terminal_growth_rate::Float64)::Float64 


    len::UInt32 = length(aftertax_ebit_vector);
    dcfₜ::Float64 = 0.0;
    valuation::Float64 = 0.0;

    length_parity::Bool = (len == length(capex_vector) && len == length(amortization_depreciation_vector)
        && len == length(change_nwc_vector));

    @assert length_parity "All the vectors must be the same length";
    @assert wacc > terminal_growth_rate "The growth rate must be lower than the WACC";


    # Computes discounted cash flows at period t and adds them
    # DCFₜ = (EBITₜ(1- τ₍c₎) + D&Aₜ   - Chang_in_NWCₜ - CAPEXₜ) / (1 + r₍w₎)^t
    @inbounds for t in 1:len 

        dcfₜ = (aftertax_ebit_vector[t] + amortization_depreciation_vector[t] - capex_vector[t]  
        - change_nwc_vector[t]) / (1 + wacc)^t;

        print("Free Cash Flow at time $t: $(dcfₜ * (1 + wacc)^t)\n",
                "Discount factor: $(round(1/(1 + wacc)^t, digits = 4))\n",
                "Discounted FCF at time $t: $dcfₜ\n\n");

        
        valuation += dcfₜ;

    end

    terminal_value = dcfₜ * (1 + terminal_growth_rate) / (wacc - terminal_growth_rate)

    print("(Undiscounted) Terminal value: $(terminal_value * (1 + wacc)^length(capex_vector))\n",
        "Discounted Terminal value: $terminal_value\n\n"); 

    # Adds long term growth as an annuity
    valuation += terminal_value;

    return valuation;

end
end





