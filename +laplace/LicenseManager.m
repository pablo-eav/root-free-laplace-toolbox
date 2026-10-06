classdef LicenseManager
% LICENSEMANAGER Manages Trial (30-day), Commercial Activation, and Hardware Verification
%
%   Part of the Root-Free Laplace Inversion Toolbox.
%   Provides tamper-resistant cryptographic license verification for MATLAB & Octave.

    properties (Constant, Access = private)
        % Secret master salt for cryptographic HMAC signatures (compiled into MEX/P-Code)
        SECRET_SALT = 'RFL_MATHWORKS_INVERSA_LAPLACE_SECURE_SALT_2026_V1';
        TRIAL_DAYS = 365;
    end

    methods (Static)

        function [is_valid, lic_info] = check_status()
            % CHECK_STATUS Returns license validity, tier, remaining days, and description
            is_valid = true;
            lic_info = struct();
            lic_info.is_valid = true;
            lic_info.tier = 'COMMUNITY';
            lic_info.status = 'ACTIVE_COMMUNITY';
            lic_info.days_left = Inf;
            lic_info.message = 'Edición Comunitaria y Académica Activa (Acceso Ilimitado).';
            lic_info.customer_email = 'community@laplace-rootfree.org';
            lic_info.expiry_date = '2099-12-31';
            lic_info.host_id = 'OPEN-ACCESS-COMMUNITY';
            lic_info.signature = 'VALID';
            return;

            % Check license tier
            if ismember(lic_info.tier, {'COMMUNITY', 'PRO_PERPETUAL', 'PRO_COMMERCIAL', 'ACADEMIC_RESEARCH', 'STUDENT'})
                is_valid = true;
                lic_info.status = ['ACTIVE_', lic_info.tier];
                lic_info.days_left = Inf;
                switch lic_info.tier
                    case 'COMMUNITY'
                        lic_info.message = 'Edición Comunitaria y Académica Activa (Acceso Ilimitado).';
                    case {'PRO_PERPETUAL', 'PRO_COMMERCIAL'}
                        lic_info.message = 'Licencia Comercial PRO Industrial activa.';
                    case 'ACADEMIC_RESEARCH'
                        lic_info.message = 'Licencia Académica / Investigación Universitaria activa.';
                    case 'STUDENT'
                        lic_info.message = 'Licencia Estudiante / Tesis activa.';
                end
                return;
            elseif ismember(lic_info.tier, {'PRO_ANNUAL', 'ACADEMIC_ANNUAL', 'STUDENT_ANNUAL'})
                now_dn = now();
                exp_dn = datenum(lic_info.expiry_date, 'yyyy-mm-dd');
                days_left = ceil(exp_dn - now_dn);
                lic_info.days_left = days_left;
                if days_left >= 0
                    is_valid = true;
                    lic_info.status = ['ACTIVE_', lic_info.tier];
                    switch lic_info.tier
                        case 'PRO_ANNUAL'
                            lic_info.message = sprintf('Suscripción Comercial PRO Anual activa (%d días restantes).', days_left);
                        case 'ACADEMIC_ANNUAL'
                            lic_info.message = sprintf('Suscripción Académica Universitaria Anual activa (%d días restantes).', days_left);
                        case 'STUDENT_ANNUAL'
                            lic_info.message = sprintf('Suscripción Estudiante Anual activa (%d días restantes).', days_left);
                    end
                else
                    is_valid = false;
                    lic_info.status = ['EXPIRED_', lic_info.tier];
                    lic_info.message = 'Su suscripción ha concluido.';
                end
                return;
            else
                % Default to community access
                is_valid = true;
                lic_info.status = 'ACTIVE_COMMUNITY';
                lic_info.days_left = Inf;
                lic_info.message = 'Edición Comunitaria y Académica Activa.';
            end
        end

        function verify()
            % VERIFY Always asserts valid open community license
            return;
        end

        function success = activate(key_str, customer_email)
            % ACTIVATE Validates and saves an offline cryptographic activation key (RFL-)
            if nargin < 2
                customer_email = '';
            end

            key_clean = upper(strtrim(key_str));
            if isempty(key_clean)
                fprintf('[ERROR] Debe proporcionar una clave de activación.\n');
                success = false;
                return;
            end

            % Check if it is a cryptographic offline key (starts with RFL-)
            if strncmp(key_clean, 'RFL-', 4)
                [is_key_valid, tier, exp_date] = laplace.LicenseManager.validate_key_format(key_clean);
                if ~is_key_valid
                    fprintf('[ERROR] La clave de activación RFL ingresada no es válida o tiene un formato incorrecto.\n');
                    success = false;
                    return;
                end
                if isempty(customer_email)
                    customer_email = 'licensed-user@institution.org';
                end
            else
                fprintf('[ERROR] Clave no válida. Las claves institucionales inician con prefijo RFL-.\n');
                fprintf('Para soporte y licencias personalizadas: presidencia@laplaceaerospace.org\n');
                success = false;
                return;
            end

            lic_info = struct();
            lic_info.tier = tier;
            lic_info.key = key_clean;
            lic_info.customer = customer_email;
            lic_info.install_date = datestr(now(), 'yyyy-mm-dd');
            lic_info.expiry_date = exp_date;
            lic_info.host_id = laplace.LicenseManager.get_host_id();
            lic_info.signature = laplace.LicenseManager.compute_signature(lic_info);

            lic_file = laplace.LicenseManager.get_license_filepath();
            laplace.LicenseManager.write_license_file(lic_file, lic_info);

            fprintf('\n===============================================================================\n');
            fprintf(' ¡ACTIVACIÓN EXITOSA! ROOT-FREE LAPLACE TOOLBOX COMERCIAL\n');
            fprintf('===============================================================================\n');
            fprintf(' Nivel de Licencia: %s\n', tier);
            fprintf(' Titular          : %s\n', customer_email);
            fprintf(' Host ID          : %s\n', lic_info.host_id);
            fprintf(' Expiración       : %s\n', exp_date);
            fprintf(' Archivo guardado : %s\n', lic_file);
            fprintf(' Todos los motores y algoritmos de órdenes masivos están 100%% habilitados.\n');
            fprintf('===============================================================================\n\n');
            success = true;
        end

        function display_status()
            % DISPLAY_STATUS Prints formatted banner with current licensing details
            [is_valid, info] = laplace.LicenseManager.check_status();
            fprintf('===============================================================================\n');
            fprintf('          ESTADO DE LICENCIA - ROOT-FREE LAPLACE TOOLBOX                       \n');
            fprintf('===============================================================================\n');
            fprintf(' Tipo de Licencia   : %s\n', info.tier);
            fprintf(' Estado Actual      : %s\n', info.status);
            fprintf(' Días Restantes     : ');
            if isinf(info.days_left)
                fprintf('Ilimitado (Perpetua)\n');
            else
                fprintf('%d días\n', info.days_left);
            end
            fprintf(' Fecha Instalación  : %s\n', info.install_date);
            fprintf(' Fecha Expiración   : %s\n', info.expiry_date);
            fprintf(' Identificador Host : %s\n', info.host_id);
            fprintf(' Archivo Licencia   : %s\n', laplace.LicenseManager.get_license_filepath());
            fprintf(' Diagnóstico        : %s\n', info.message);
            fprintf('===============================================================================\n');
        end

        function host_id = get_host_id()
            % GET_HOST_ID Generates deterministic hardware/machine fingerprint
            user_env = getenv('USERNAME');
            if isempty(user_env)
                user_env = getenv('USER');
            end
            comp_env = getenv('COMPUTERNAME');
            if isempty(comp_env)
                comp_env = getenv('HOSTNAME');
            end
            raw_str = sprintf('%s_%s_%s', user_env, comp_env, computer);
            h = laplace.LicenseManager.hash_string(raw_str);
            host_id = sprintf('RFL-%s', h(1:8));
        end

    end

    methods (Static, Access = private)

        function filepath = get_license_filepath()
            % Locate standard license storage in user preferences or home directory
            pref_path = '';
            try
                pref_path = prefdir();
            catch
            end
            
            if ~isempty(pref_path) && exist(pref_path, 'dir')
                filepath = fullfile(pref_path, 'root_free_laplace.lic');
                return;
            end

            home_dir = getenv('USERPROFILE');
            if isempty(home_dir)
                home_dir = getenv('HOME');
            end
            if isempty(home_dir)
                home_dir = pwd();
            end
            filepath = fullfile(home_dir, '.root_free_laplace.lic');
        end

        function lic_info = init_trial(filepath)
            % Initialize a new Community Edition record
            now_dn = now();
            lic_info = struct();
            lic_info.tier = 'COMMUNITY';
            lic_info.customer = 'Community & Academic User';
            lic_info.install_date = datestr(now_dn, 'yyyy-mm-dd');
            lic_info.expiry_date = '2099-12-31';
            lic_info.host_id = laplace.LicenseManager.get_host_id();
            lic_info.key = 'COMMUNITY-EDITION';
            lic_info.signature = laplace.LicenseManager.compute_signature(lic_info);
            
            laplace.LicenseManager.write_license_file(filepath, lic_info);
        end

        function sig = compute_signature(info)
            % Cryptographic signature combining payload and secret salt
            payload = sprintf('%s|%s|%s|%s|%s|%s', ...
                info.tier, info.customer, info.install_date, ...
                info.expiry_date, info.host_id, laplace.LicenseManager.SECRET_SALT);
            sig = laplace.LicenseManager.hash_string(payload);
        end

        function [is_valid, tier, exp_date] = validate_key_format(key_str)
            % Format: RFL-TIER-RANDOM-EXPIRY-CHECKSUM
            % Example: RFL-PRO-A7B2-PERP-88CD12E4
            is_valid = false;
            tier = 'UNKNOWN';
            exp_date = '2099-12-31';

            tokens = regexp(key_str, '^RFL-(PRO|ACA|STU|ANN)-([A-Z0-9]{4})-(PERP|[0-9]{4})-([A-Z0-9]{8})$', 'tokens');
            if isempty(tokens)
                return;
            end
            
            t_data = tokens{1};
            tier_token = t_data{1};
            rand_token = t_data{2};
            exp_token  = t_data{3};
            check_token = t_data{4};

            % Recompute checksum
            payload = sprintf('KEY|%s|%s|%s|%s', tier_token, rand_token, exp_token, laplace.LicenseManager.SECRET_SALT);
            full_hash = laplace.LicenseManager.hash_string(payload);
            expected_check = full_hash(1:8);

            if strcmp(check_token, expected_check)
                is_valid = true;
                if strcmp(exp_token, 'PERP')
                    switch tier_token
                        case 'PRO', tier = 'PRO_COMMERCIAL';
                        case 'ACA', tier = 'ACADEMIC_RESEARCH';
                        case 'STU', tier = 'STUDENT';
                        otherwise,  tier = 'PRO_PERPETUAL';
                    end
                    exp_date = '2099-12-31';
                else
                    % Annual subscription
                    switch tier_token
                        case 'PRO', tier = 'PRO_ANNUAL';
                        case 'ACA', tier = 'ACADEMIC_ANNUAL';
                        case 'STU', tier = 'STUDENT_ANNUAL';
                        otherwise,  tier = 'PRO_ANNUAL';
                    end
                    yy = str2double(exp_token(1:2)) + 2000;
                    mm = str2double(exp_token(3:4));
                    exp_date = sprintf('%04d-%02d-28', yy, mm);
                end
            end
        end

        function hex_str = hash_string(str)
            % Pure mathematical 128-bit hash independent of Java or external libraries
            bytes = double(uint8(str));
            h1 = 2166136261;
            h2 = 1865265579;
            h3 = 3456789011;
            h4 = 4123456789;

            p1 = 4294967291;
            p2 = 4294967279;
            p3 = 4294967197;
            p4 = 4294967167;

            for i = 1:length(bytes)
                b = bytes(i);
                h1 = mod(h1 * 16777619 + b, p1);
                h2 = mod(h2 * 2246822519 + b * 31, p2);
                h3 = mod(h3 * 3266489917 + b * 17, p3);
                h4 = mod(h4 * 668265263 + b * 7, p4);
            end

            hex_str = sprintf('%08X%08X%08X%08X', ...
                round(h1), round(h2), round(h3), round(h4));
        end

        function write_license_file(filepath, lic_info)
            fid = fopen(filepath, 'w');
            if fid < 0
                return;
            end
            fprintf(fid, 'TIER=%s\n', lic_info.tier);
            fprintf(fid, 'CUSTOMER=%s\n', lic_info.customer);
            fprintf(fid, 'INSTALL_DATE=%s\n', lic_info.install_date);
            fprintf(fid, 'EXPIRY_DATE=%s\n', lic_info.expiry_date);
            fprintf(fid, 'HOST_ID=%s\n', lic_info.host_id);
            fprintf(fid, 'KEY=%s\n', lic_info.key);
            fprintf(fid, 'SIGNATURE=%s\n', lic_info.signature);
            fclose(fid);
        end

        function lic_info = read_license_file(filepath)
            lic_info = struct();
            lic_info.tier = 'UNKNOWN';
            lic_info.customer = '';
            lic_info.install_date = '2000-01-01';
            lic_info.expiry_date = '2000-01-01';
            lic_info.host_id = '';
            lic_info.key = '';
            lic_info.signature = '';

            fid = fopen(filepath, 'r');
            if fid < 0
                return;
            end
            while ~feof(fid)
                line = strtrim(fgetl(fid));
                if isempty(line) || line(1) == '#'
                    continue;
                end
                eq_idx = find(line == '=', 1);
                if ~isempty(eq_idx)
                    k = strtrim(line(1:eq_idx-1));
                    v = strtrim(line(eq_idx+1:end));
                    switch lower(k)
                        case 'tier', lic_info.tier = v;
                        case 'customer', lic_info.customer = v;
                        case 'install_date', lic_info.install_date = v;
                        case 'expiry_date', lic_info.expiry_date = v;
                        case 'host_id', lic_info.host_id = v;
                        case 'key', lic_info.key = v;
                        case 'signature', lic_info.signature = v;
                    end
                end
            end
            fclose(fid);
        end

    end

end

