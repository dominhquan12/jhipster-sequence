import { IProductCategory } from 'app/entities/product-category/product-category.model';

export interface IProduct {
  id: number;
  code?: string | null;
  name?: string | null;
  price?: number | null;
  productCategory?: IProductCategory | null;
}

export type NewProduct = Omit<IProduct, 'id'> & { id: null };
