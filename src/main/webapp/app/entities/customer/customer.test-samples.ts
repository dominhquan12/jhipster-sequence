import dayjs from 'dayjs/esm';

import { ICustomer, NewCustomer } from './customer.model';

export const sampleWithRequiredData: ICustomer = {
  id: 3366,
};

export const sampleWithPartialData: ICustomer = {
  id: 9679,
  email: 'XuanKhoa.Tran@hotmail.com',
};

export const sampleWithFullData: ICustomer = {
  id: 4149,
  firstName: 'Thanh Toản',
  lastName: 'Phạm',
  birthday: dayjs('2025-07-05'),
  phoneNumber: 'selfishly',
  email: 'ThangLoi79@hotmail.com',
};

export const sampleWithNewData: NewCustomer = {
  id: null,
};

Object.freeze(sampleWithNewData);
Object.freeze(sampleWithRequiredData);
Object.freeze(sampleWithPartialData);
Object.freeze(sampleWithFullData);
