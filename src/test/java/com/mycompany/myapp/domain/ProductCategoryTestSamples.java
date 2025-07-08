package com.mycompany.myapp.domain;

import java.util.Random;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;

public class ProductCategoryTestSamples {

    private static final Random random = new Random();
    private static final AtomicLong longCount = new AtomicLong(random.nextInt() + (2 * Integer.MAX_VALUE));

    public static ProductCategory getProductCategorySample1() {
        return new ProductCategory().id(1L).code("code1").name("name1");
    }

    public static ProductCategory getProductCategorySample2() {
        return new ProductCategory().id(2L).code("code2").name("name2");
    }

    public static ProductCategory getProductCategoryRandomSampleGenerator() {
        return new ProductCategory().id(longCount.incrementAndGet()).code(UUID.randomUUID().toString()).name(UUID.randomUUID().toString());
    }
}
