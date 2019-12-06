function [CoM, CoB, componentMass] = COM_COB_Function(hullThickness, final_ID)
    [X_com, Y_com, Z_com] = getCOM(hullThickness, final_ID); % m
    [X_COB, Y_COB, Z_COB] = getCOB(hullThickness, final_ID); % m
    CoM = [X_com, Y_com, Z_com];
    CoB = [X_COB, Y_COB, Z_COB];

    %%%%%%%%% CENTER OF MASS %%%%%%%%%%%%
    function [COM_X, COM_Y, COM_Z] = getCOM(hullThickness, final_ID)
        %%%%%%%%% Properties %%%%%%%%%%%%%%%%
        SUM_MASS = 3292.72; % kg, referes to the entire sub minus hull and frame
        componentMass = SUM_MASS;
        SUB_COM_X = 1.17927166;
        SUB_COM_Y = -0.11048635;
        SUB_COM_Z = 0.00420349;

        HULL_OR = 1; % m
        hull_IR = HULL_OR - hullThickness; %m
        hull_Volume = (4/3) * pi * (HULL_OR^3 - hull_IR^3); % m^3
        ACRYLIC_DENSITY = 1180; %kg/m^3
        HULL_MASS = hull_Volume * ACRYLIC_DENSITY; % kg, acrylic density * Hull shell volume
        HULL_COM_X = 0.0007;
        HULL_COM_Y = -0.0343;
        HULL_COM_Z = -0.0002;

        TUBE_OD = 0.1; %m,
        FRAME_EFFECTIVE_LENGTH = 51.14; %m, approximation from cad
        FRAME_VOLUME = (pi / 4) * (TUBE_OD^2 - final_ID^2) * FRAME_EFFECTIVE_LENGTH; %m^3
        FRAME_DENSITY = 782; %(kg/m^3) SS 2205
        FRAME_MASS = FRAME_VOLUME * FRAME_DENSITY; %kg, Tube thickness give cross cestion area * effective length * steel density
        FRAME_COM_X = 1.471;
        FRAME_COM_Y = -0.0328;
        FRAME_COM_Z = 0;

        total_Mass = SUM_MASS + HULL_MASS + FRAME_MASS

        %%%%%%%%%%%%%%% CENTER OF MASS CALC %%%%%%%%%%%%%%%%%
        COM_X = (SUB_COM_X * SUM_MASS + HULL_COM_X * HULL_MASS + FRAME_COM_X * FRAME_MASS) / total_Mass;
        COM_Y = (SUB_COM_Y * SUM_MASS + HULL_COM_Y * HULL_MASS + FRAME_COM_Y * FRAME_MASS) / total_Mass;
        COM_Z = (SUB_COM_Z * SUM_MASS + HULL_COM_Z * HULL_MASS + FRAME_COM_Z * FRAME_MASS) / total_Mass;
    end

    function [COB_X, COB_Y, COB_Z] = getCOB(hullThickness, final_ID)

        %%%%%%%%% PROPERTIES %%%%%%%%%%%%%%%%
        WATER_DENSITY = 1029; %kg/m^3

        SUB_VOLUME = 1.06557107; % m^3 , based on solidworks sans pressure haul and frame
        SUB_BOUYANCY = SUB_VOLUME * WATER_DENSITY; %kg
        SUB_COB_X = 1.471; %m
        SUB_COB_Y = -0.2124; %m
        SUB_COB_Z = 0.00267; %m

        HULL_VOLUME = 4/3 * pi * (1)^3; % m^3
        HULL_BOUYANCY = HULL_VOLUME * WATER_DENSITY; % kg
        HULL_COB_X = 0.0007; %m
        HULL_COB_Y = -0.0343; %m
        HULL_COB_Z = -0.0002; %m

        TUBE_OD = .1; %m
        FRAME_EFFECTIVE_LENGTH = 51.14; %m, approximation from cad
        FRAME_VOLUME = (pi / 4) * TUBE_OD^2 * FRAME_EFFECTIVE_LENGTH; %m^3
        FRAME_BOUYANCY = FRAME_VOLUME * WATER_DENSITY; %kg
        FRAME_COB_X = 1.471; %m
        FRAME_COB_Y = -0.0328; %m
        FRAME_COB_Z = 0; %m

        tota_bouyancy = SUB_BOUYANCY + HULL_BOUYANCY + FRAME_BOUYANCY

        %%%%%%%%%%%%% CENTER OG BOUYANCY CALC %%%%%%%%%%%%%%%%%%%

        COB_X = (SUB_COB_X * SUB_BOUYANCY + HULL_COB_X * HULL_BOUYANCY + FRAME_COB_X * FRAME_BOUYANCY) / tota_bouyancy;
        COB_Y = (SUB_COB_Y * SUB_BOUYANCY + HULL_COB_Y * HULL_BOUYANCY + FRAME_COB_Y * FRAME_BOUYANCY) / tota_bouyancy;
        COB_Z = (SUB_COB_Z * SUB_BOUYANCY + HULL_COB_Z * HULL_BOUYANCY + FRAME_COB_Z * FRAME_BOUYANCY) / tota_bouyancy;
    end

end
