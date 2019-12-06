function [hullThickness, hatchThickness, hullVolume, hullMass, batteries] = HHGP(time, depth, thrusterPower)
    %
    % description.
    %
    % @since 1.0.0
    % @param {type} [name] description.
    % @return {type} [name] description.
    % @see dependencies
    %
    ROOT_2 = 1.41421356237;
    EPDM_YOUNGS_MODULUS = 6000000; % Pa
    GASKET_COMPRESSION_RATIO = 0.2;
    K_ACRYLIC = 0.209; % W/m-K
    SAFETY_FACTOR_HULL = 4;
    SAFETY_FACTOR_HATCH = 3;
    ACRYLIC_DENSITY = 1180; %kg/m^3
    RADIUS_OUTER = (2240/2)/1000; %m
    SIGMA_SUSTAINED_ACRYLIC = 10000000; %Pa
    ELASTIC_MODULUS_ACRYLIC = 2760000000; %Pa
    HATCH_HOLE_RADIUS = 0.3; %m
    UTS_STAINLESS_STEEL = 448000000; %Pa
    ELASTIC_MODULUS_SS = 193000000000; %Pa
    TIME = time; %hours
    DEPTH = depth; %Depth is 1000m, this term will be paramaterization value
    THRUSTER_POWER = thrusterPower; %kW
    BATTERY_CAP = 10.32; %kWh

    %function testing
    [hullVolume, hullMass, hullThickness] = get_hull_thickness(DEPTH);
    hatchThickness = get_hatch_thickness(hullThickness, DEPTH);
    gasketForce = get_sealing_force(0.08, 0.1, 0.0032, GASKET_COMPRESSION_RATIO, EPDM_YOUNGS_MODULUS);
    batteries = ceil(get_power_usage() * TIME / BATTERY_CAP);

    function power = get_power_usage()
        qAcrylic = get_heat_loss(hullThickness, K_ACRYLIC);
        power = qAcrylic / 1000 + 4 * THRUSTER_POWER * 0.1;
    end

    function thermalLoss = get_heat_loss(t, k)
        h_air = 10.45;
        h_water = 2000;
        resistance = (1 / (h_air * 4 * pi * (RADIUS_OUTER - t)^2)) + (1 / (h_water * 4 * pi * (RADIUS_OUTER)^2)) + (t / (k * 4 * pi * (RADIUS_OUTER)^2));
        thermalLoss = (20 - 0.2) / resistance;
    end

    function sealingForce = get_sealing_force(innerDiameter, outerDiameter, restingThickness, compressionPercent, youngsModulus)
        compressedThickness = restingThickness - restingThickness * compressionPercent;
        area = (pi / 4) * (outerDiameter^2 - innerDiameter^2);
        deltaL = restingThickness - compressedThickness;
        sealingForce = (area * youngsModulus * deltaL) / restingThickness;
    end

    function output = get_hatch_thickness(hullThickness, targetDepth)
        targetDepth = targetDepth * SAFETY_FACTOR_HATCH;
        p = pressure_at_depth(targetDepth);
        t = 0.001;
        maxStress = UTS_STAINLESS_STEEL + 1;

        while (maxStress > UTS_STAINLESS_STEEL) || (buckling_thickness(maxStress, RADIUS_OUTER, t, ELASTIC_MODULUS_SS) > t)
            t = t + 0.0001;
            maxStress = (p * (hullThickness * (ROOT_2 / 2) + HATCH_HOLE_RADIUS)^2) / ((2 * (ROOT_2 / 2)) * (HATCH_HOLE_RADIUS) * t);
        end

        buckling_thickness(maxStress, RADIUS_OUTER, t, ELASTIC_MODULUS_SS) * 100;
        output = t;
    end

    function [v_out, m_out, t_out] = get_hull_thickness(targetDepth)
        targetDepth = targetDepth * SAFETY_FACTOR_HULL;
        pressure = pressure_at_depth(targetDepth);
        thickness = 0.0001;
        stress = hull_stress(pressure, thickness, RADIUS_OUTER);
        t_buckle = buckling_thickness(stress, RADIUS_OUTER, thickness, ELASTIC_MODULUS_ACRYLIC);

        while (t_buckle > thickness) || (SIGMA_SUSTAINED_ACRYLIC < stress)
            thickness = thickness + 0.001;
            stress = hull_stress(pressure, thickness, RADIUS_OUTER);
            t_buckle = buckling_thickness(stress, RADIUS_OUTER, thickness, ELASTIC_MODULUS_ACRYLIC);
        end

        m_out = ((4/3) * pi * RADIUS_OUTER^3 - (4/3) * pi * (RADIUS_OUTER - thickness)^3) * ACRYLIC_DENSITY;
        v_out = (4/3) * pi * RADIUS_OUTER^3;
        t_out = thickness;
    end

    function sigma_hull = hull_stress(p, t, r)
        psi = 0.01;
        theta = 0.01;
        sigma_hull = (p * (t + r) * (t + r) * psi * theta) / (4 * ((t^2) + 2 * r * t) * (psi + theta)^2);
    end

    function t_buckle = buckling_thickness(stress, r, t, sigma)
        p_cr = stress * (t * t);
        t_buckle = ((6 * r * r * p_cr) / (8 * sigma))^0.25;
    end

    %     function dif = percentDifference(x, y)
    %         dif = abs(100*((x-y)/y));
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: pressure_at_depth
    % -------------------------------------------
    % Calculates pressure of water at input depth
    %
    % @params: depth
    %
    % @returns: P_water
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function P_water = pressure_at_depth(depth)
        rho = 1032.85; %density of seawater (kg/m^3)
        g = 9.81; % gravity(m/s)
        P_water = rho * g * depth;
    end

end
