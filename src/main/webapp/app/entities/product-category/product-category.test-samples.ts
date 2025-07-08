import { IProductCategory, NewProductCategory } from './product-category.model';

export const sampleWithRequiredData: IProductCategory = {
  id: 14928,
};

export const sampleWithPartialData: IProductCategory = {
  id: 17767,
};

export const sampleWithFullData: IProductCategory = {
  id: 13570,
  code: 'happy possession widow',
  name: 'pro unexpectedly forenenst',
};

export const sampleWithNewData: NewProductCategory = {
  id: null,
};

Object.freeze(sampleWithNewData);
Object.freeze(sampleWithRequiredData);
Object.freeze(sampleWithPartialData);
Object.freeze(sampleWithFullData);
