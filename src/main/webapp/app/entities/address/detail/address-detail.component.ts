import { Component, input } from '@angular/core';
import { RouterModule } from '@angular/router';

import SharedModule from 'app/shared/shared.module';
import { IAddress } from '../address.model';

@Component({
  selector: 'jhi-address-detail',
  templateUrl: './address-detail.component.html',
  imports: [SharedModule, RouterModule],
})
export class AddressDetailComponent {
  address = input<IAddress | null>(null);

  previousState(): void {
    window.history.back();
  }
}
