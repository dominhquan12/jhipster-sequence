import dayjs from 'dayjs/esm';
import { IAddress } from 'app/entities/address/address.model';
import { IProduct } from 'app/entities/product/product.model';

export interface ICustomer {
  id: number;
  firstName?: string | null;
  lastName?: string | null;
  birthday?: dayjs.Dayjs | null;
  phoneNumber?: string | null;
  email?: string | null;
  address?: IAddress | null;
  product?: IProduct | null;
}

export type NewCustomer = Omit<ICustomer, 'id'> & { id: null };
