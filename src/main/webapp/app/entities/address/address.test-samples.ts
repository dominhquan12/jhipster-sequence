import { IAddress, NewAddress } from './address.model';

export const sampleWithRequiredData: IAddress = {
  id: 2568,
};

export const sampleWithPartialData: IAddress = {
  id: 21652,
  houseNumber: 'times',
};

export const sampleWithFullData: IAddress = {
  id: 16440,
  houseNumber: 'ouch molasses',
  street: 'Tô Knolls',
  country: 'Séc',
};

export const sampleWithNewData: NewAddress = {
  id: null,
};

Object.freeze(sampleWithNewData);
Object.freeze(sampleWithRequiredData);
Object.freeze(sampleWithPartialData);
Object.freeze(sampleWithFullData);
