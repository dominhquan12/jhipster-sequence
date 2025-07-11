package com.mycompany.myapp.domain;

import static com.mycompany.myapp.domain.AddressTestSamples.*;
import static com.mycompany.myapp.domain.CustomerTestSamples.*;
import static com.mycompany.myapp.domain.ProductTestSamples.*;
import static org.assertj.core.api.Assertions.assertThat;

import com.mycompany.myapp.web.rest.TestUtil;
import org.junit.jupiter.api.Test;

class CustomerTest {

    @Test
    void equalsVerifier() throws Exception {
        TestUtil.equalsVerifier(Customer.class);
        Customer customer1 = getCustomerSample1();
        Customer customer2 = new Customer();
        assertThat(customer1).isNotEqualTo(customer2);

        customer2.setId(customer1.getId());
        assertThat(customer1).isEqualTo(customer2);

        customer2 = getCustomerSample2();
        assertThat(customer1).isNotEqualTo(customer2);
    }

    @Test
    void addressTest() {
        Customer customer = getCustomerRandomSampleGenerator();
        Address addressBack = getAddressRandomSampleGenerator();

        customer.setAddress(addressBack);
        assertThat(customer.getAddress()).isEqualTo(addressBack);

        customer.address(null);
        assertThat(customer.getAddress()).isNull();
    }

    @Test
    void productTest() {
        Customer customer = getCustomerRandomSampleGenerator();
        Product productBack = getProductRandomSampleGenerator();

        customer.setProduct(productBack);
        assertThat(customer.getProduct()).isEqualTo(productBack);

        customer.product(null);
        assertThat(customer.getProduct()).isNull();
    }
}
