import { Routes } from '@angular/router';

import { UserRouteAccessService } from 'app/core/auth/user-route-access.service';
import { ASC } from 'app/config/navigation.constants';
import AddressResolve from './route/address-routing-resolve.service';

const addressRoute: Routes = [
  {
    path: '',
    loadComponent: () => import('./list/address.component').then(m => m.AddressComponent),
    data: {
      defaultSort: `id,${ASC}`,
    },
    canActivate: [UserRouteAccessService],
  },
  {
    path: ':id/view',
    loadComponent: () => import('./detail/address-detail.component').then(m => m.AddressDetailComponent),
    resolve: {
      address: AddressResolve,
    },
    canActivate: [UserRouteAccessService],
  },
  {
    path: 'new',
    loadComponent: () => import('./update/address-update.component').then(m => m.AddressUpdateComponent),
    resolve: {
      address: AddressResolve,
    },
    canActivate: [UserRouteAccessService],
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./update/address-update.component').then(m => m.AddressUpdateComponent),
    resolve: {
      address: AddressResolve,
    },
    canActivate: [UserRouteAccessService],
  },
];

export default addressRoute;
