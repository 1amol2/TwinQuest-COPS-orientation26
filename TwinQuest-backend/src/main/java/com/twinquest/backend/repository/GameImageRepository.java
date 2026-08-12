package com.twinquest.backend.repository;

import com.twinquest.backend.model.GameImage;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface GameImageRepository extends MongoRepository<GameImage, String> {
}