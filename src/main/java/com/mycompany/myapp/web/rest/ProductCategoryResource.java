package com.mycompany.myapp.web.rest;

import com.mycompany.myapp.domain.ProductCategory;
import com.mycompany.myapp.repository.ProductCategoryRepository;
import com.mycompany.myapp.web.rest.errors.BadRequestAlertException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import tech.jhipster.web.util.HeaderUtil;
import tech.jhipster.web.util.ResponseUtil;

/**
 * REST controller for managing {@link com.mycompany.myapp.domain.ProductCategory}.
 */
@RestController
@RequestMapping("/api/product-categories")
@Transactional
public class ProductCategoryResource {

    private static final Logger LOG = LoggerFactory.getLogger(ProductCategoryResource.class);

    private static final String ENTITY_NAME = "productCategory";

    @Value("${jhipster.clientApp.name}")
    private String applicationName;

    private final ProductCategoryRepository productCategoryRepository;

    public ProductCategoryResource(ProductCategoryRepository productCategoryRepository) {
        this.productCategoryRepository = productCategoryRepository;
    }

    /**
     * {@code POST  /product-categories} : Create a new productCategory.
     *
     * @param productCategory the productCategory to create.
     * @return the {@link ResponseEntity} with status {@code 201 (Created)} and with body the new productCategory, or with status {@code 400 (Bad Request)} if the productCategory has already an ID.
     * @throws URISyntaxException if the Location URI syntax is incorrect.
     */
    @PostMapping("")
    public ResponseEntity<ProductCategory> createProductCategory(@RequestBody ProductCategory productCategory) throws URISyntaxException {
        LOG.debug("REST request to save ProductCategory : {}", productCategory);
        if (productCategory.getId() != null) {
            throw new BadRequestAlertException("A new productCategory cannot already have an ID", ENTITY_NAME, "idexists");
        }
        productCategory = productCategoryRepository.save(productCategory);
        return ResponseEntity.created(new URI("/api/product-categories/" + productCategory.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(applicationName, true, ENTITY_NAME, productCategory.getId().toString()))
            .body(productCategory);
    }

    /**
     * {@code PUT  /product-categories/:id} : Updates an existing productCategory.
     *
     * @param id the id of the productCategory to save.
     * @param productCategory the productCategory to update.
     * @return the {@link ResponseEntity} with status {@code 200 (OK)} and with body the updated productCategory,
     * or with status {@code 400 (Bad Request)} if the productCategory is not valid,
     * or with status {@code 500 (Internal Server Error)} if the productCategory couldn't be updated.
     * @throws URISyntaxException if the Location URI syntax is incorrect.
     */
    @PutMapping("/{id}")
    public ResponseEntity<ProductCategory> updateProductCategory(
        @PathVariable(value = "id", required = false) final Long id,
        @RequestBody ProductCategory productCategory
    ) throws URISyntaxException {
        LOG.debug("REST request to update ProductCategory : {}, {}", id, productCategory);
        if (productCategory.getId() == null) {
            throw new BadRequestAlertException("Invalid id", ENTITY_NAME, "idnull");
        }
        if (!Objects.equals(id, productCategory.getId())) {
            throw new BadRequestAlertException("Invalid ID", ENTITY_NAME, "idinvalid");
        }

        if (!productCategoryRepository.existsById(id)) {
            throw new BadRequestAlertException("Entity not found", ENTITY_NAME, "idnotfound");
        }

        productCategory = productCategoryRepository.save(productCategory);
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(applicationName, true, ENTITY_NAME, productCategory.getId().toString()))
            .body(productCategory);
    }

    /**
     * {@code PATCH  /product-categories/:id} : Partial updates given fields of an existing productCategory, field will ignore if it is null
     *
     * @param id the id of the productCategory to save.
     * @param productCategory the productCategory to update.
     * @return the {@link ResponseEntity} with status {@code 200 (OK)} and with body the updated productCategory,
     * or with status {@code 400 (Bad Request)} if the productCategory is not valid,
     * or with status {@code 404 (Not Found)} if the productCategory is not found,
     * or with status {@code 500 (Internal Server Error)} if the productCategory couldn't be updated.
     * @throws URISyntaxException if the Location URI syntax is incorrect.
     */
    @PatchMapping(value = "/{id}", consumes = { "application/json", "application/merge-patch+json" })
    public ResponseEntity<ProductCategory> partialUpdateProductCategory(
        @PathVariable(value = "id", required = false) final Long id,
        @RequestBody ProductCategory productCategory
    ) throws URISyntaxException {
        LOG.debug("REST request to partial update ProductCategory partially : {}, {}", id, productCategory);
        if (productCategory.getId() == null) {
            throw new BadRequestAlertException("Invalid id", ENTITY_NAME, "idnull");
        }
        if (!Objects.equals(id, productCategory.getId())) {
            throw new BadRequestAlertException("Invalid ID", ENTITY_NAME, "idinvalid");
        }

        if (!productCategoryRepository.existsById(id)) {
            throw new BadRequestAlertException("Entity not found", ENTITY_NAME, "idnotfound");
        }

        Optional<ProductCategory> result = productCategoryRepository
            .findById(productCategory.getId())
            .map(existingProductCategory -> {
                if (productCategory.getCode() != null) {
                    existingProductCategory.setCode(productCategory.getCode());
                }
                if (productCategory.getName() != null) {
                    existingProductCategory.setName(productCategory.getName());
                }

                return existingProductCategory;
            })
            .map(productCategoryRepository::save);

        return ResponseUtil.wrapOrNotFound(
            result,
            HeaderUtil.createEntityUpdateAlert(applicationName, true, ENTITY_NAME, productCategory.getId().toString())
        );
    }

    /**
     * {@code GET  /product-categories} : get all the productCategories.
     *
     * @return the {@link ResponseEntity} with status {@code 200 (OK)} and the list of productCategories in body.
     */
    @GetMapping("")
    public List<ProductCategory> getAllProductCategories() {
        LOG.debug("REST request to get all ProductCategories");
        return productCategoryRepository.findAll();
    }

    /**
     * {@code GET  /product-categories/:id} : get the "id" productCategory.
     *
     * @param id the id of the productCategory to retrieve.
     * @return the {@link ResponseEntity} with status {@code 200 (OK)} and with body the productCategory, or with status {@code 404 (Not Found)}.
     */
    @GetMapping("/{id}")
    public ResponseEntity<ProductCategory> getProductCategory(@PathVariable("id") Long id) {
        LOG.debug("REST request to get ProductCategory : {}", id);
        Optional<ProductCategory> productCategory = productCategoryRepository.findById(id);
        return ResponseUtil.wrapOrNotFound(productCategory);
    }

    /**
     * {@code DELETE  /product-categories/:id} : delete the "id" productCategory.
     *
     * @param id the id of the productCategory to delete.
     * @return the {@link ResponseEntity} with status {@code 204 (NO_CONTENT)}.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProductCategory(@PathVariable("id") Long id) {
        LOG.debug("REST request to delete ProductCategory : {}", id);
        productCategoryRepository.deleteById(id);
        return ResponseEntity.noContent()
            .headers(HeaderUtil.createEntityDeletionAlert(applicationName, true, ENTITY_NAME, id.toString()))
            .build();
    }
}
