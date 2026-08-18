package com.twinquest.backend.service;

import com.twinquest.backend.model.GameImage;
import com.twinquest.backend.repository.GameImageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ImageService {

    private final GameImageRepository gameImageRepository;

    public GameImage generatePuzzleImage(String pairId) {

        int width = 800;
        int height = 500;

        BufferedImage image =
                new BufferedImage(
                        width,
                        height,
                        BufferedImage.TYPE_INT_RGB
                );

        Graphics2D graphics =
                image.createGraphics();

        graphics.setColor(
                new Color(245, 235, 220)
        );

        graphics.fillRect(
                0,
                0,
                width,
                height
        );

        graphics.setColor(
                new Color(91, 55, 40)
        );

        graphics.setFont(
                new Font(
                        "SansSerif",
                        Font.BOLD,
                        42
                )
        );

        graphics.drawString(
                "TwinQuest",
                250,
                220
        );

        graphics.setFont(
                new Font(
                        "SansSerif",
                        Font.PLAIN,
                        24
                )
        );

        graphics.drawString(
                "Pair " + pairId.substring(0, 6),
                300,
                270
        );

        graphics.dispose();

        String full =
                encodeImage(image);

        BufferedImage left =
                image.getSubimage(
                        0,
                        0,
                        width / 2,
                        height
                );

        BufferedImage right =
                image.getSubimage(
                        width / 2,
                        0,
                        width / 2,
                        height
                );

        GameImage gameImage =
                GameImage.builder()
                        .imageUrl(full)
                        .leftHalfUrl(encodeImage(left))
                        .rightHalfUrl(encodeImage(right))
                        .build();

        return gameImageRepository.save(gameImage);
    }

    private String encodeImage(
            BufferedImage image
    ) {

        try {

            ByteArrayOutputStream output =
                    new ByteArrayOutputStream();

            ImageIO.write(
                    image,
                    "png",
                    output
            );

            String base64 =
                    Base64.getEncoder()
                            .encodeToString(
                                    output.toByteArray()
                            );

            return "data:image/png;base64," + base64;

        } catch (Exception e) {

            throw new RuntimeException(
                    "Failed to generate puzzle image",
                    e
            );
        }
    }
}