% Sistem Deteksi Warna Optimized untuk Penderita Buta Warna
% Focus pada warna-warna yang sulit dibedakan oleh penderita buta warna
clc; clear; close all;

% Inisialisasi video
vid = VideoReader('teswarna.mp4');

% PENGATURAN TEXT POSITION - FIXED KE POJOK KIRI ATAS
TEXT_POSITION = 1;  % Fixed ke Top-Left saja

% PENGATURAN BATASAN DETEKSI - FIX UNTUK ERROR
MAX_COLORS_PER_FRAME = 3;  % Maksimal 3 warna per frame

% WARNA LENGKAP UNTUK DETEKSI (12 warna)
colorRanges = containers.Map();

% Warna Primer dan Sekunder
colorRanges('Merah1') = [0.0, 0.04, 0.6, 1.0, 0.3, 1.0];     % Merah tegas
colorRanges('Merah2') = [0.92, 1.0, 0.6, 1.0, 0.3, 1.0];     % Merah wrap-around
colorRanges('Hijau') = [0.25, 0.45, 0.4, 1.0, 0.2, 1.0];     % Hijau
colorRanges('Biru') = [0.55, 0.75, 0.4, 1.0, 0.2, 1.0];      % Biru
colorRanges('Kuning') = [0.12, 0.25, 0.4, 1.0, 0.4, 1.0];    % Kuning
colorRanges('Orange') = [0.05, 0.12, 0.6, 1.0, 0.4, 1.0];    % Orange
colorRanges('Ungu') = [0.75, 0.85, 0.4, 1.0, 0.2, 1.0];      % Ungu

% Warna Tambahan
colorRanges('Pink') = [0.85, 0.95, 0.3, 0.8, 0.4, 1.0];      % Pink
colorRanges('Cyan') = [0.45, 0.55, 0.4, 1.0, 0.3, 1.0];      % Cyan
colorRanges('Coklat') = [0.05, 0.15, 0.3, 0.8, 0.1, 0.6];    % Coklat
colorRanges('Putih') = [0.0, 1.0, 0.0, 0.2, 0.8, 1.0];       % Putih
colorRanges('Hitam') = [0.0, 1.0, 0.0, 1.0, 0.0, 0.3];       % Hitam

% Nama warna untuk display
colorNames = containers.Map();
colorNames('Merah1') = 'MERAH'; colorNames('Merah2') = 'MERAH';
colorNames('Hijau') = 'HIJAU'; colorNames('Biru') = 'BIRU';
colorNames('Kuning') = 'KUNING'; colorNames('Orange') = 'ORANGE';
colorNames('Ungu') = 'UNGU'; colorNames('Pink') = 'PINK';
colorNames('Cyan') = 'CYAN'; colorNames('Coklat') = 'COKLAT';
colorNames('Putih') = 'PUTIH'; colorNames('Hitam') = 'HITAM';

% Warna kontras untuk bounding box
boxColors = containers.Map();
boxColors('Merah1') = [1, 1, 0]; boxColors('Merah2') = [1, 1, 0];    % Yellow
boxColors('Hijau') = [1, 1, 0]; boxColors('Biru') = [1, 1, 0];       % Yellow
boxColors('Kuning') = [1, 0, 0]; boxColors('Orange') = [0, 0, 1];     % Red, Blue
boxColors('Ungu') = [1, 1, 0]; boxColors('Pink') = [1, 1, 0];        % Yellow
boxColors('Cyan') = [1, 0, 0]; boxColors('Coklat') = [1, 1, 0];      % Red, Yellow
boxColors('Putih') = [1, 0, 0]; boxColors('Hitam') = [1, 1, 0];      % Red, Yellow

fprintf('=== SISTEM DETEKSI WARNA UNTUK BUTA WARNA (TERBATAS) ===\n');
fprintf('Maksimal 3 warna terbesar per frame dengan text putih\n');
fprintf('Posisi Text: Top-Left (Fixed)\n');

frameCount = 0;
figure('Name', 'Optimized Color Detection for Color Blind', 'Position', [100, 100, 900, 700]);

% Parameter untuk mengurangi noise detection
MIN_AREA = 1000;        % Area minimum objek (diperbesar)
MIN_SOLIDITY = 0.6;     % Soliditas minimum (bentuk lebih solid)
MAX_OBJECTS_PER_COLOR = 3;  % Maksimum 3 objek per warna per frame

while hasFrame(vid)
    frameCount = frameCount + 1;
    
    % Baca dan proses frame
    RGB = readFrame(vid);
    HSV = rgb2hsv(RGB);
    H = HSV(:, :, 1); S = HSV(:, :, 2); V = HSV(:, :, 3);
    
    imshow(RGB); hold on;
    
    totalDetections = 0;
    colorList = {};
    allDetections = [];  % Untuk menyimpan semua deteksi
    
    % Iterasi untuk setiap warna dan kumpulkan semua deteksi
    colorKeys = keys(colorRanges);
    for i = 1:length(colorKeys)
        colorKey = colorKeys{i};
        range = colorRanges(colorKey);
        
        % Threshold HSV dengan range yang lebih tegas
        h_min = range(1); h_max = range(2);
        s_min = range(3); s_max = range(4);
        v_min = range(5); v_max = range(6);
        
        % Buat mask
        mask = (H >= h_min & H <= h_max) & ...
               (S >= s_min & S <= s_max) & ...
               (V >= v_min & V <= v_max);
        
        % Enhanced pre-processing untuk mengurangi noise
        mask = medfilt2(mask, [5, 5]);           % Median filter lebih besar
        se1 = strel('disk', 3);
        mask = imopen(mask, se1);                % Opening lebih agresif
        se2 = strel('disk', 4);
        mask = imclose(mask, se2);               % Closing lebih agresif
        mask = bwareaopen(mask, MIN_AREA);       % Area minimum lebih besar
        
        % Analisis objek dengan filter tambahan
        labeled = bwlabel(mask);
        stats = regionprops(labeled, 'BoundingBox', 'Area', 'Centroid', ...
                           'Solidity', 'Extent', 'MajorAxisLength', 'MinorAxisLength');
        
        % Sort berdasarkan area (objek terbesar dulu)
        if ~isempty(stats)
            areas = [stats.Area];
            [~, sortIdx] = sort(areas, 'descend');
            stats = stats(sortIdx);
        end
        
        objectCount = 0;
        for j = 1:length(stats)
            % Filter berdasarkan kriteria yang lebih ketat
            area = stats(j).Area;
            solidity = stats(j).Solidity;
            extent = stats(j).Extent;
            aspectRatio = stats(j).MajorAxisLength / stats(j).MinorAxisLength;
            
            % Kriteria seleksi objek yang lebih ketat
            if area > MIN_AREA && ...
               solidity > MIN_SOLIDITY && ...
               extent > 0.3 && ...
               aspectRatio < 5 && ...
               objectCount < MAX_OBJECTS_PER_COLOR
                
                objectCount = objectCount + 1;
                
                % Simpan deteksi untuk sorting nanti
                detection = struct();
                detection.colorKey = colorKey;
                detection.colorName = colorNames(colorKey);
                detection.boxColor = boxColors(colorKey);
                detection.bb = stats(j).BoundingBox;
                detection.area = area;
                detection.centroid = stats(j).Centroid;
                
                allDetections = [allDetections; detection];
            end
        end
    end
    
    % BATASI HANYA 3 WARNA TERBESAR
    if ~isempty(allDetections)
        % Sort berdasarkan area terbesar
        areas = [allDetections.area];
        [~, sortIdx] = sort(areas, 'descend');
        allDetections = allDetections(sortIdx);
        
        % Ambil hanya warna-warna unik dengan area terbesar
        selectedColors = {};
        selectedDetections = [];
        
        for i = 1:length(allDetections)
            colorName = allDetections(i).colorName;
            
            % Jika warna belum ada dan belum mencapai batas 3 warna
            if ~any(strcmp(selectedColors, colorName)) && length(selectedColors) < MAX_COLORS_PER_FRAME
                selectedColors{end+1} = colorName;
            end
            
            % Jika warna sudah terpilih, tambahkan ke deteksi
            if any(strcmp(selectedColors, colorName))
                selectedDetections = [selectedDetections; allDetections(i)];
            end
        end
        
        % Gambar hanya deteksi yang terpilih
        for i = 1:length(selectedDetections)
            detection = selectedDetections(i);
            
            % Gambar bounding box
            rectangle('Position', detection.bb, 'EdgeColor', detection.boxColor, 'LineWidth', 3);
            
            % Hitung posisi text - FIXED KE TOP-LEFT
            [textX, textY, hAlign, vAlign] = calculateTextPosition(detection.bb, 1);
            
            % Tampilkan text dengan warna PUTIH
            text(textX, textY, detection.colorName, ...
                'Color', [1, 1, 1], ...  % PUTIH
                'FontSize', 12, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', hAlign, ...
                'VerticalAlignment', vAlign, ...
                'BackgroundColor', [0, 0, 0, 0.8], ...
                'EdgeColor', [1, 1, 1], ...  % PUTIH
                'LineWidth', 1.5, ...
                'Margin', 3);
            
            totalDetections = totalDetections + 1;
        end
        
        % Update colorList dengan warna yang terpilih
        colorList = selectedColors;
    end
    
    % Display informasi frame dengan prioritas warna
    if ~isempty(colorList)
        colorStr = strjoin(colorList, ', ');
    else
        colorStr = 'Tidak ada warna terdeteksi';
    end
    
    title(sprintf('Frame: %d | Deteksi: %d objek | Warna: %s', ...
          frameCount, totalDetections, colorStr), ...
          'FontSize', 12, 'Color', 'white', 'BackgroundColor', [0, 0, 0, 0.8]);
    
    
    % Progress dengan info deteksi
    if mod(frameCount, 30) == 0
        fprintf('Frame %d | Objek valid: %d | Warna: %s\n', ...
                frameCount, totalDetections, colorStr);
    end
    pause(0.03);
end

fprintf('\n=== KONFIGURASI FINAL ===\n');
fprintf('Total frame: %d\n', frameCount);
fprintf('Maksimal 3 warna terbesar per frame\n');
fprintf('Posisi text: Top-Left (fixed)\n');

%% FUNGSI PENDUKUNG

function [textX, textY, hAlign, vAlign] = calculateTextPosition(bb, position)
    % FIXED KE TOP-LEFT SAJA
    textX = bb(1) - 2;
    textY = bb(2) - 8;
    hAlign = 'left'; 
    vAlign = 'bottom';
    
    % Jika terlalu dekat dengan tepi atas, pindah ke dalam bounding box
    if textY < 20
        textY = bb(2) + 20; 
        vAlign = 'top'; 
    end
    
    % Boundary protection
    if textX < 10, textX = 10; end
    if textY < 20, textY = 20; end
end

function displayOptimizationSummary()
    fprintf('\n=== KONFIGURASI SISTEM ===\n');
    fprintf('1. ✓ 12 warna tersedia untuk deteksi\n');
    fprintf('2. ✓ BATASAN: Maksimal 3 warna per frame\n');
    fprintf('3. ✓ Prioritas: Area terbesar yang dipilih\n');
    fprintf('4. ✓ Text selalu PUTIH untuk konsistensi\n');
    fprintf('5. ✓ Posisi text FIXED di Top-Left\n');
    fprintf('6. ✓ Min area filter: 1000 px\n');
    fprintf('7. ✓ Solidity filter (>0.6)\n');
    fprintf('8. ✓ Max 3 objek per warna yang terpilih\n');
    fprintf('9. ✓ Enhanced morphological operations\n');
    fprintf('10. ✓ Background text semi-transparent\n');
    fprintf('\nWarna yang dapat dideteksi:\n');
    fprintf('MERAH, HIJAU, BIRU, KUNING, ORANGE, UNGU,\n');
    fprintf('PINK, CYAN, COKLAT, PUTIH, HITAM\n');
    fprintf('\n*** HANYA 3 WARNA TERBESAR DITAMPILKAN PER FRAME ***\n');
end

displayOptimizationSummary();