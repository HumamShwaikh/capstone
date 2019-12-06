function [final_OD, final_ID, final_tube_thickness] = HydroStaticBucklingCode(depth)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       Variables and Method Calls for Hydrostatic Tube Analysis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n_given = 1.5;

    OD = 0.1;
    ID = 0.085;
    %inner outer radius
    r_i = ID / 2;
    r_o = OD / 2;
    r_max = 0.05;
    t_min = OD - ID;

    E = 190e9; %Mod of Elasticity SS 2205 (Pa)
    mat_yield = 448e6; %Yield stress of SS 2205 (Pa)
    P_inner = 0.101e6; %Inner tube pressure at ATM (MPa)

    P_outer = pressure_at_depth(depth);
    P_ftotal = pressure_equalize_tube(P_outer, P_inner);

    buckle_status = critical_buckling(t_min, r_max, P_ftotal, E); %Tube 0.015 m OD

    if buckle_status == 0
        disp('Tube will not buckle')
    end

    r_dist = radial_distance(r_i, t_min); %radial distance for later calculation

    %stresses acting on tube
    s_r = radial_stress(r_i, t_min, P_inner, P_outer, r_dist);
    s_t = tangent_stress(r_i, t_min, P_inner, P_outer, r_dist);
    m_s = tube_shear(s_r, s_t);

    %safety factor based on hydrostatic pressure
    tube_safety_factor_hydro(s_r, s_t, m_s, mat_yield);

    %Multiple material buckling test
    [n_SS2205, n_SS304, n_SAH36, n_AL5052, n_AL6061] = tube_materials_hydro_safety_factor(r_i, r_o, t_min, r_max, P_ftotal, P_inner, P_outer, r_dist);
    test_n1 = optimal_material_n_hydrostatics(n_SS2205, n_SS304, n_SAH36, n_AL5052, n_AL6061);

    safe_test = is_it_safe(test_n1, n_given);

    [tube_n_min, tube_thick_min] = get_tube_min_thickness(P_inner, P_outer, r_dist, mat_yield)

    disp('Therefore under current conditions, even the thinnest manufacturer thickness will not buckle')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       Variables and Method Calls for Lifting Tube Analysis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Based on FBD from Analysis Report we obtain the following constants
    %Critical member load = Lifting Scenario

    max_bending_cr = 12649.01; % Max bending stress on critical member(Nm)
    max_shear_cr = 59544.71; % Max bending stress on critical member(Nm)
    cr_OD = 0.1; % outer diameter (m)
    cr_ID = 0.085; % inner diameter (m)
    yield_stress = 4.48e8; % write code to try multiple materials

    test_bend = get_bending_stress(max_bending_cr, cr_OD, cr_ID);
    test_shear = get_shear_stress(max_shear_cr, cr_OD, cr_ID);

    test_n2 = get_cr_safety_factor(yield_stress, test_bend, test_shear);

    optimal_material_n_crit_load(test_bend, test_shear, 4.48e8, 2.15e8, 3.52e8, 2.55e8, 2.76e8);

    safe_test_2 = is_it_safe(test_n2, n_given);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           Verification of Final Tube Dimensions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    final_tube_thickness = get_final_tube_thickness(depth);
    final_OD = OD;
    final_ID = (final_OD - 2 * final_tube_thickness);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Best Safety Factor choice based on HydroStatic Pressure
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: pressure_equalize_tube
    % -------------------------------------------
    % Calculates total pressure resultant acting on tube
    %
    % @params: P_water
    %
    % @returns: P_total
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function P_total = pressure_equalize_tube(P_water, P_i)
        P_total = P_water - P_i;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: critical_buckling
    % -------------------------------------------
    % Calculates critical buckling for various tube dimensions
    %
    % @params: t_min, r_max, P_water
    %
    % @returns: buckle_status (bool)
    %   0 - false
    %   1 - true
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function buckle_status = critical_buckling(t_min, r_max, P_water, E_val)
        v = 0.3; %Poisson Ratio SS 2205

        %Critical Buckling Pressure
        P_buckle = (E_val / (4 * (1 - (v)^2))) * (t_min / r_max)^3;

        %Conditonal Check of Buckling Status
        if P_buckle < P_water
            buckle_status = true;
        else
            buckle_status = false;
        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: radial_distance
    % -------------------------------------------
    % Calculates radial distance used in stress calculations
    %
    % @params: r_inner, thickness
    %
    % @returns: r_distance
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function r_distance = radial_distance(r_inner, thickness)
        r_distance = r_inner + (thickness / 2);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: radial_stress
    % -------------------------------------------
    % Calculates radial stress on tube
    %
    % @params: inner_radius, outer_radius, inner_Pressure, outer_Pressure,
    % radial_distance
    %
    % @returns: radial_stress
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function stress_r = radial_stress(r_i, r_o, P_i, P_o, r_d)
        stress_r = ((((r_i)^2) * (P_i)) / (((r_o)^2) - ((r_i)^2))) - ((((r_i)^2) * ((r_o)^2) * (P_i - P_o)) / (((r_o)^2) - ((r_i)^2))) * (1 / (r_d)^2);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: tangent_stress
    % -------------------------------------------
    % Calculates tangential stress on tube
    %
    % @params: inner_radius, outer_radius, inner_Pressure, outer_Pressure,
    % radial_distance
    %
    % @returns: tangent_stress
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function stress_t = tangent_stress(r_i, r_o, P_i, P_o, r_d)
        stress_t = ((((r_i)^2) * (P_i)) / (((r_o)^2) - ((r_i)^2))) + ((((r_i)^2) * ((r_o)^2) * (P_i - P_o)) / (((r_o)^2) - ((r_i)^2))) * (1 / (r_d)^2);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: max_shear
    % -------------------------------------------
    % Calculates max shear on tube
    %
    % @params: stress_r, stress_t
    %
    % @returns: max_shear
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function max_shear = tube_shear(stress_r, stress_t)
        max_shear = (stress_r - (-stress_t)) / 2;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: tube_safety_factor_hydro
    % -------------------------------------------
    % Calculates safety factor of tube selection based on Hydrodynamic loading
    %
    % @params: stress_r, stress_t, max_shear
    %
    % @returns: safety_factor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function hydro_safety_factor = tube_safety_factor_hydro(stress_r, stress_t, max_shear, mat_yield)
        val = (stress_r)^2 + (stress_t)^2 + 3 * ((max_shear)^2);
        von_mises = sqrt(val);

        hydro_safety_factor = (mat_yield / von_mises);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: tube_materials_hydro_safety_factor
    % -------------------------------------------
    % Compare various materials to obtain buckling of various materials
    %
    % @params: t_min, r_max, P_water
    %
    % @returns: bool if buckles
    %   0 - false
    %   1 - true
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [n_SS2205, n_SS304, n_SAH36, n_AL5052, n_AL6061] = tube_materials_hydro_safety_factor(r_i, r_o, t_min, r_max, P_water, P_i, P_o, r_d)
        s_r = radial_stress(r_i, r_o, P_i, P_o, r_d);
        s_t = tangent_stress(r_i, r_o, P_i, P_o, r_d);
        m_s = tube_shear(s_r, s_t);

        E_SS2205 = 190e9; %Mod of Elasticity SS 2205 (Pa)
        y_SS2205 = 448e6; %Yield Strength SS 2205 (Pa)

        E_SS304 = 193e9; %Mod of Elasticity SS 304 (Pa)
        y_SS304 = 215e6; %Yield Strength SS 304 (Pa)

        E_SAH36 = 200e9; %Mod of Elasticity SAH36 (Pa)
        y_SAH36 = 352e6; %Yield Strength SAH36 (Pa)

        E_AL5052 = 70e9; %Mod of Elasticity AL 5052 (Pa)
        y_AL5052 = 255e6; %Yield Strength AL 5052 (Pa)

        E_AL6061 = 68.9e9; %Mod of Elasticity AL 6061 (Pa)
        y_AL6061 = 76e6; %Yield Strength AL 6061 (Pa)

        %If the material and geometry doesn't buckle, calculate safety factor
        buckle_SS2205 = critical_buckling(t_min, r_max, P_water, E_SS2205);

        if buckle_SS2205 == 0
            n_SS2205 = tube_safety_factor_hydro(s_r, s_t, m_s, y_SS2205);
        end

        buckle_SS304 = critical_buckling(t_min, r_max, P_water, E_SS304);

        if buckle_SS304 == 0
            n_SS304 = tube_safety_factor_hydro(s_r, s_t, m_s, y_SS304);
        end

        buckle_SAH36 = critical_buckling(t_min, r_max, P_water, E_SAH36);

        if buckle_SAH36 == 0
            n_SAH36 = tube_safety_factor_hydro(s_r, s_t, m_s, y_SAH36);
        end

        buckle_AL5052 = critical_buckling(t_min, r_max, P_water, E_AL5052);

        if buckle_AL5052 == 0
            n_AL5052 = tube_safety_factor_hydro(s_r, s_t, m_s, y_AL5052);
        end

        buckle_AL6061 = critical_buckling(t_min, r_max, P_water, E_AL6061);

        if buckle_AL6061 == 0
            n_AL6061 = tube_safety_factor_hydro(s_r, s_t, m_s, y_AL6061);
        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: optimal_material_n_hydrostatics
    % -------------------------------------------
    % Compare various safety factors and return the best material to use
    %
    % @params: n_SS2205, n_SS304, n_SAH36, n_AL5052, n_AL6061
    %
    % @returns: material_choice
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function material_choice = optimal_material_n_hydrostatics(n_SS2205, n_SS304, n_SAH36, n_AL5052, n_AL6061)
        arr = [n_SS2205 n_SS304 n_SAH36 n_AL5052 n_AL6061];

        vec = [n_SS2205, n_SS304, n_SAH36, n_AL5052, n_AL6061];
        C = {'SS 2205', 'SS 304', 'SAH 36', 'AL 5052', 'AL 6061'};
        [new, idx] = sort(vec);
        D = C(idx); % sort the names into the same order
        D(2, :) = num2cell(new);
        fprintf('%10s %d\n', D{:})

        disp('The best material for hydrostatic pressure loading is: SS2205')
        material_choice = max(arr)

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: is_it_safe
    % -------------------------------------------
    % compare safety factor with desired safety factor
    %
    % @params: n_solved, n_given
    %
    % @returns: bool (safe?)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function safe = is_it_safe(n_solved, n_given)

        if n_solved >= n_given
            safe = true;
            disp('Material selected is safe');
        else
            safe = false;
            disp('Material selected is not safe');
        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_tube_min_thickness
    % -------------------------------------------
    % Knowing SS 2205 is the best material, determine how thin we can go before
    % the material will buckle
    %
    % @params: n_solved, n_given
    %
    % @returns: tube_min_thickness, tube_n_min
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [tube_n_min, tube_thick_min] = get_tube_min_thickness(P_inner, P_outer, r_dist, mat_yield)
        %stresses acting on tube
        ID = 0.085;
        OD = 0.1;
        t_min = OD - ID;

        while t_min > 0.005
            ID = ID + 0.001;
            r_i = ID / 2;
            t_min = 0.1 - ID;

            s_r = radial_stress(r_i, t_min, P_inner, P_outer, r_dist);
            s_t = tangent_stress(r_i, t_min, P_inner, P_outer, r_dist);
            m_s = tube_shear(s_r, s_t);

            %safety factor based on hydrostatic pressure
            tube_n_min = tube_safety_factor_hydro(s_r, s_t, m_s, mat_yield);
            tube_thick_min = t_min;
        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Best Safety Factor choice based on Lifting Scenario
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_cr_y
    % -------------------------------------------
    % Determine the geometric y const
    %
    % @params: cr_OD
    %
    % @returns: cr_y
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cr_y = get_cr_y(cr_OD)
        cr_y = cr_OD / 2;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_cr_Ic
    % -------------------------------------------
    % Determine the moment of inertia for pipe geometry
    %
    % @params: cr_OD, cr_ID
    %
    % @returns: cr_Ic
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cr_Ic = get_cr_Ic(cr_OD, cr_ID)
        OR = cr_OD / 2;
        IR = cr_ID / 2;
        cr_Ic = pi * ((OR^4) - (IR^4)) / 4;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_cr_Q
    % -------------------------------------------
    % Determine the Q constant, based on geometry of tube
    %
    % @params: cr_OD, cr_ID
    %
    % @returns: cr_Q
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cr_Q = get_cr_Q(cr_OD, cr_ID)
        OR = cr_OD / 2;
        IR = cr_ID / 2;
        cr_Q = (2/3) * ((OR^3) - (IR^3));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_cr_b
    % -------------------------------------------
    % Determine the b constant, based on geometry of tube
    %
    % @params: cr_OD, cr_ID
    %
    % @returns: cr_b
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cr_b = get_cr_b(cr_OD, cr_ID)
        OR = cr_OD / 2;
        IR = cr_ID / 2;
        cr_b = 2 * (OR - IR);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_bending_stress
    % -------------------------------------------
    %  Obtain the bending stress when crtiical member in lifting scenario
    %
    % @params: max_bending_cr, cr_OD, cr_ID
    %
    % @returns: bending_stress
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function bending_stress = get_bending_stress(max_bending_cr, cr_OD, cr_ID)
        y = get_cr_y(cr_OD);
        I = get_cr_Ic(cr_OD, cr_ID);
        bending_stress = (max_bending_cr * y) / (I);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_shear_stress
    % -------------------------------------------
    %  Obtain the shear stress when crtiical member in lifting scenario
    %
    % @params: max_shear_cr, cr_OD, cr_ID
    %
    % @returns: shear_stress
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function shear_stress = get_shear_stress(max_shear_cr, cr_OD, cr_ID)
        Q = get_cr_Q(cr_OD, cr_ID);
        I = get_cr_Ic(cr_OD, cr_ID);
        b = get_cr_b(cr_OD, cr_ID);
        shear_stress = (max_shear_cr * Q) / (I * b);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_cr_safety_factor
    % -------------------------------------------
    %  Obtain the safety factor when crtiical member in lifting scenario
    %
    % @params: yield_stress, bend, shear
    %
    % @returns: cr_n
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cr_n = get_cr_safety_factor(yield_stress, bend, shear)
        von_mises = sqrt((bend)^2 + 3 * (shear)^2);
        cr_n = yield_stress / von_mises;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: optimal_material_n_crit_load
    % -------------------------------------------
    % Compare various safety factors and return the best material to use for
    % lifting scenario
    %
    % @params: y_SS2205, y_SS304, y_SAH36, y_AL5052, y_AL6061
    %
    % @returns: material_choice_cr
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function material_choice_cr = optimal_material_n_crit_load(bend, shear, y_SS2205, y_SS304, y_SAH36, y_AL5052, y_AL6061)
        n_cr_SS2205 = get_cr_safety_factor(y_SS2205, bend, shear);
        n_cr_SS304 = get_cr_safety_factor(y_SS304, bend, shear);
        n_cr_SAH36 = get_cr_safety_factor(y_SAH36, bend, shear);
        n_cr_AL5052 = get_cr_safety_factor(y_AL5052, bend, shear);
        n_cr_AL6061 = get_cr_safety_factor(y_AL6061, bend, shear);

        arr = [n_cr_SS2205 n_cr_SS304 n_cr_SAH36 n_cr_AL5052 n_cr_AL6061];

        vec = [n_cr_SS2205, n_cr_SS304, n_cr_SAH36, n_cr_AL5052, n_cr_AL6061];
        C = {'SS 2205', 'SS 304', 'SAH 36', 'AL 5052', 'AL 6061'};
        [new, idx] = sort(vec);
        D = C(idx); % sort the names into the same order
        D(2, :) = num2cell(new);
        fprintf('%10s %d\n', D{:})

        disp('The best material for lifting loading scenario is also: SS 2205')
        material_choice_cr = max(arr)

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Best Safety Factor choice for Welded Joints (Critical Member)
    %   The critical member was selected as it undergoes the largest load.
    %   Therefore, it can be assumed using this thickenss everywhere will
    %   provide a sufficientyly safe submarine.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_shear_weld
    % -------------------------------------------
    %  Obtain the shear stress from the shear force
    %
    % @params: shear, OD, ID
    %
    % @returns: shear_weld
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function shear_weld = get_shear_weld(shear, OD, ID)
        shear_weld = (4 * (shear)) / (pi * ((OD^2) - (ID^2)));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_stress_weld
    % -------------------------------------------
    %  Obtain the stress from the shear force
    %
    % @params: normal, OD, ID
    %
    % @returns: stress_weld
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function stress_weld = get_stress_weld(normal, OD, ID)
        stress_weld = (4 * (normal)) / (pi * ((OD^2) - (ID^2)));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_bend_stress_weld
    % -------------------------------------------
    %  Obtain the bending stress from the shear force
    %
    % @params: moment, OD, ID
    %
    % @returns: bend_stress_weld
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function bend_stress_weld = get_bend_stress_weld(moment, OD, ID)
        bend_stress_weld = (32 * (moment)) / ((pi * ((OD)^3) * (1 - (ID / OD)^4)));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: get_n_weld
    % -------------------------------------------
    %  Obtain the safety factor for the weld
    %
    % @params: stress, bend_stress, shear
    %
    % @returns: n_weld
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function n_weld = get_n_weld(stress, bend_stress, shear, yield)
        von_mises_weld = sqrt(stress^2 + bend_stress^2 + (3 * shear^2));
        n_weld = (yield) / (von_mises_weld);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: determine_sf_thick_weld
    % -------------------------------------------
    %  (Iterative) Obtain the safety factor and thickness for the weld
    %
    % @params: stress, bend_stress, shear
    %
    % @returns: n_weld, thickness
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [n_weld] = determine_sf_thick_weld(weld_shear, weld_normal, weld_bend, weld_yield, weld_n, weld_OD, weld_ID)

        while weld_n < 2
            weld_ID = weld_ID - 0.0001;
            s_w = get_shear_weld(weld_shear, weld_OD, weld_ID);
            st_w = get_stress_weld(weld_normal, weld_OD, weld_ID);
            b_w = get_bend_stress_weld(weld_bend, weld_OD, weld_ID);
            weld_n = get_n_weld(b_w, st_w, s_w, weld_yield);
        end

        if weld_ID > 0.095
            disp('Minimum value for thickness is 5mm, therefore use lowest possible thickness')
            weld_ID = 0.095;
            s_w = get_shear_weld(weld_shear, weld_OD, weld_ID);
            st_w = get_stress_weld(weld_normal, weld_OD, weld_ID);
            b_w = get_bend_stress_weld(weld_bend, weld_OD, weld_ID);
            n_weld = get_n_weld(b_w, st_w, s_w, weld_yield);
        else
            n_weld = weld_n;
        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: determine_final_thickness
    % -------------------------------------------
    %  take in the thicknesses from other calculations, select the largest
    %  thickness
    %
    % @params: thick_1, thick_2, thick_3
    %
    % @returns: final_tube_thickness
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [final_OD, final_ID, final_tube_thickness] = determine_final_thickness(thick_1, thick_2)
        final_OD = 0.1;

        if thick_1 > thick_2
            final_tube_thickness = thick_1;
        else
            final_tube_thickness = thick_2;
        end

        final_ID = final_OD - final_tube_thickness;
    end

    function final_tube_thickness = get_final_tube_thickness(depth)
        thick_min = 0.005;
        thick_max = 0.015;
        max_depth = 1000;
        min_depth = 100;

        m = (thick_max - thick_min) / (max_depth - min_depth);
        final_tube_thickness = (m * (depth)) + (3.889e-3);
    end

end
