export interface IAddress {
  id: number;
  houseNumber?: string | null;
  street?: string | null;
  country?: string | null;
}

export type NewAddress = Omit<IAddress, 'id'> & { id: null };
