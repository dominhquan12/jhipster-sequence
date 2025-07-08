import { IProduct, NewProduct } from './product.model';

export const sampleWithRequiredData: IProduct = {
  id: 11737,
};

export const sampleWithPartialData: IProduct = {
  id: 23011,
  name: 'definite shampoo downright',
};

export const sampleWithFullData: IProduct = {
  id: 4403,
  code: 'cafe',
  name: 'along amongst',
  price: 12917.62,
};

export const sampleWithNewData: NewProduct = {
  id: null,
};

Object.freeze(sampleWithNewData);
Object.freeze(sampleWithRequiredData);
Object.freeze(sampleWithPartialData);
Object.freeze(sampleWithFullData);
