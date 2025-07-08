import { Routes } from '@angular/router';

const routes: Routes = [
  {
    path: 'authority',
    data: { pageTitle: 'myApp.adminAuthority.home.title' },
    loadChildren: () => import('./admin/authority/authority.routes'),
  },
  {
    path: 'address',
    data: { pageTitle: 'myApp.address.home.title' },
    loadChildren: () => import('./address/address.routes'),
  },
  {
    path: 'customer',
    data: { pageTitle: 'myApp.customer.home.title' },
    loadChildren: () => import('./customer/customer.routes'),
  },
  {
    path: 'product',
    data: { pageTitle: 'myApp.product.home.title' },
    loadChildren: () => import('./product/product.routes'),
  },
  {
    path: 'product-category',
    data: { pageTitle: 'myApp.productCategory.home.title' },
    loadChildren: () => import('./product-category/product-category.routes'),
  },
  /* jhipster-needle-add-entity-route - JHipster will add entity modules routes here */
];

export default routes;
