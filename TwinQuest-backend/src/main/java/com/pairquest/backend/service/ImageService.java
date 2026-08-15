package com.pairquest.backend.service;

import org.springframework.stereotype.Service;
import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ImageService {

    private final Map<String, String[]> pairImageHalves = new ConcurrentHashMap<>();

    public ImageService() {
        // Pre-generate sample orientation puzzle images
        generatePuzzleHalves("PAIR_1");
        generatePuzzleHalves("PAIR_2");
        generatePuzzleHalves("PAIR_3");
    }

    public String[] getOrGenerateHalves(String pairId) {
        return pairImageHalves.computeIfAbsent(pairId, this::generatePuzzleHalves);
    }

    private String[] generatePuzzleHalves(String pairId) {
        try {
            int width = 400;
            int height = 400;
            BufferedImage fullImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
            Graphics2D g2d = fullImage.createGraphics();

            // Draw vibrant orientation pattern based on pairId hash
            int hash = Math.abs(pairId.hashCode());
            g2d.setColor(new Color((hash * 67) % 255, (hash * 131) % 255, (hash * 199) % 255));
            g2d.fillRect(0, 0, width, height);

            g2d.setColor(new Color((hash * 211) % 255, (hash * 179) % 255, (hash * 97) % 255));
            g2d.fillOval(50, 50, 300, 300);

            g2d.setColor(Color.WHITE);
            g2d.setFont(new Font("SansSerif", Font.BOLD, 36));
            g2d.drawString("TWINQUEST #" + pairId.replace("PAIR_", ""), 60, 210);
            g2d.dispose();

            // Crop Left Half (0 to 200)
            BufferedImage leftHalf = fullImage.getSubimage(0, 0, width / 2, height);
            // Crop Right Half (200 to 400)
            BufferedImage rightHalf = fullImage.getSubimage(width / 2, 0, width / 2, height);

            String leftBase64 = imageToBase64(leftHalf);
            String rightBase64 = imageToBase64(rightHalf);

            return new String[]{leftBase64, rightBase64};
        } catch (Exception e) {
            return new String[]{"", ""};
        }
    }

    private String imageToBase64(BufferedImage img) throws Exception {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(img, "png", baos);
        return "data:image/png;base64," + Base64.getEncoder().encodeToString(baos.toByteArray());
    }
}
