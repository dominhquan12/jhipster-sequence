import { Injectable } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';

import { IProductCategory, NewProductCategory } from '../product-category.model';

/**
 * A partial Type with required key is used as form input.
 */
type PartialWithRequiredKeyOf<T extends { id: unknown }> = Partial<Omit<T, 'id'>> & { id: T['id'] };

/**
 * Type for createFormGroup and resetForm argument.
 * It accepts IProductCategory for edit and NewProductCategoryFormGroupInput for create.
 */
type ProductCategoryFormGroupInput = IProductCategory | PartialWithRequiredKeyOf<NewProductCategory>;

type ProductCategoryFormDefaults = Pick<NewProductCategory, 'id'>;

type ProductCategoryFormGroupContent = {
  id: FormControl<IProductCategory['id'] | NewProductCategory['id']>;
  code: FormControl<IProductCategory['code']>;
  name: FormControl<IProductCategory['name']>;
};

export type ProductCategoryFormGroup = FormGroup<ProductCategoryFormGroupContent>;

@Injectable({ providedIn: 'root' })
export class ProductCategoryFormService {
  createProductCategoryFormGroup(productCategory: ProductCategoryFormGroupInput = { id: null }): ProductCategoryFormGroup {
    const productCategoryRawValue = {
      ...this.getFormDefaults(),
      ...productCategory,
    };
    return new FormGroup<ProductCategoryFormGroupContent>({
      id: new FormControl(
        { value: productCategoryRawValue.id, disabled: true },
        {
          nonNullable: true,
          validators: [Validators.required],
        },
      ),
      code: new FormControl(productCategoryRawValue.code),
      name: new FormControl(productCategoryRawValue.name),
    });
  }

  getProductCategory(form: ProductCategoryFormGroup): IProductCategory | NewProductCategory {
    return form.getRawValue() as IProductCategory | NewProductCategory;
  }

  resetForm(form: ProductCategoryFormGroup, productCategory: ProductCategoryFormGroupInput): void {
    const productCategoryRawValue = { ...this.getFormDefaults(), ...productCategory };
    form.reset(
      {
        ...productCategoryRawValue,
        id: { value: productCategoryRawValue.id, disabled: true },
      } as any /* cast to workaround https://github.com/angular/angular/issues/46458 */,
    );
  }

  private getFormDefaults(): ProductCategoryFormDefaults {
    return {
      id: null,
    };
  }
}
