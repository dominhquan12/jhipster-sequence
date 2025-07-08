export interface IProductCategory {
  id: number;
  code?: string | null;
  name?: string | null;
}

export type NewProductCategory = Omit<IProductCategory, 'id'> & { id: null };
