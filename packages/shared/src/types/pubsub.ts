// PubSub event types broadcast by the backend to all clients in a week's group.

export type PubSubEventType =
  | 'itemAdded'
  | 'itemUpdated'
  | 'itemDeleted'
  | 'mealAdded'
  | 'mealUpdated'
  | 'mealDeleted';

export interface PubSubEventBase {
  type: PubSubEventType;
  weekId: string;
}

export interface ItemAddedEvent extends PubSubEventBase {
  type: 'itemAdded';
  item: import('./models.js').GroceryItem;
}

export interface ItemUpdatedEvent extends PubSubEventBase {
  type: 'itemUpdated';
  item: import('./models.js').GroceryItem;
}

export interface ItemDeletedEvent extends PubSubEventBase {
  type: 'itemDeleted';
  itemId: string;
}

export interface MealAddedEvent extends PubSubEventBase {
  type: 'mealAdded';
  meal: import('./models.js').Meal;
}

export interface MealUpdatedEvent extends PubSubEventBase {
  type: 'mealUpdated';
  meal: import('./models.js').Meal;
}

export interface MealDeletedEvent extends PubSubEventBase {
  type: 'mealDeleted';
  mealId: string;
}

export type PubSubEvent =
  | ItemAddedEvent
  | ItemUpdatedEvent
  | ItemDeletedEvent
  | MealAddedEvent
  | MealUpdatedEvent
  | MealDeletedEvent;
