import type { GroceryItem, Meal, Week } from './models.js';

// ---------------------------------------------------------------------------
// Week
// ---------------------------------------------------------------------------

export type CreateWeekRequest = {
  label: string;
  startDate: string; // YYYY-MM-DD
};

export type CreateWeekResponse = Week;

export type GetWeeksResponse = Week[];

export type GetWeekResponse = Week & {
  meals: Meal[];
  items: GroceryItem[];
};

export type DuplicateWeekRequest = {
  newLabel: string;
  newStartDate: string; // YYYY-MM-DD
};

export type DuplicateWeekResponse = Week;

// ---------------------------------------------------------------------------
// Meals
// ---------------------------------------------------------------------------

export type CreateMealRequest = {
  text: string;
  order: number;
};

export type CreateMealResponse = Meal;

export type UpdateMealRequest = Partial<Pick<Meal, 'text' | 'order'>>;

export type UpdateMealResponse = Meal;

// ---------------------------------------------------------------------------
// Grocery items
// ---------------------------------------------------------------------------

export type CreateItemRequest = {
  text: string;
};

export type CreateItemResponse = GroceryItem;

export type UpdateItemRequest = Partial<Pick<GroceryItem, 'text' | 'completed'>>;

export type UpdateItemResponse = GroceryItem;

// ---------------------------------------------------------------------------
// PubSub negotiate
// ---------------------------------------------------------------------------

export type NegotiateResponse = {
  url: string; // Signed Web PubSub client connection URL
};
