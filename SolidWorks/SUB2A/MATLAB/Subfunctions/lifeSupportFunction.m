function [Oxygen_m3, CO2_Canisters, Airflow_m3PerMin] = lifeSupportFunction(time, hullThickness)
    hull_inner_radius = 1 - hullThickness; %1-geththickness

    [Oxygen_m3, CO2_Canisters, Airflow_m3PerMin] = lifeSupport(time, hull_inner_radius)

    function [oxygen, co2_scrubber_canisters, airFlow] = lifeSupport(DIVING_TIME, radius)
        %source: https://www.ncbi.nlm.nih.gov/pubmed/9066318, http://www.aimdrjournal.com/pdf/vol3Issue1/AN1_ClR_Gamal.pdf

        %%%%%%% Properties Setup; Human Consumption, Air Properties %%%%%%%%%

        HUMAN_AIR_INTAKE = 0.48; % m^3/h/Person
        NUMBER_OF_PASSENGERS = 2; %Persons
        OXYGEN_CONSUMED_PER_BREATH = 0.0724; % percent by volume, worst case from text
        CO2_EXHALED = 0.053; %Percent by Volume
        CO2_ABSORBED_PER_CANISTER = 20; % PERSONS*HOURS
        AIRCHANGES_PER_HOUR = 12; %from DNVGL Regulation
        hull_volume = 4/3 * pi * radius^3;

        %%%%%%%% MATH %%%%%%%%%%%%%
        OxygenRequired = DIVING_TIME * HUMAN_AIR_INTAKE * NUMBER_OF_PASSENGERS * OXYGEN_CONSUMED_PER_BREATH;
        CO2CanistersRequired = DIVING_TIME * NUMBER_OF_PASSENGERS / CO2_ABSORBED_PER_CANISTER;
        AirflowRate = hull_volume * AIRCHANGES_PER_HOUR;

        %%%%%%%% Outputs %%%%%%%%%%
        oxygen = OxygenRequired; %m^3 @ 0.1MPa
        co2_scrubber_canisters = ceil(CO2CanistersRequired); %" m^3 @ 0.1MPa"
        airFlow = AirflowRate / 60; % " m^3/min @ 0.1MPa"

    end

end
