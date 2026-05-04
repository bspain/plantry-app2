// Data model types for Plantry App 2
// Reflects the Cosmos DB documents stored in each container.

export interface User {
  id: string;
  householdId: string;
  email: string;
  displayName: string;
  createdAt: string; // ISO 8601
}

export interface Household {
  id: string;
  name: string;
  createdAt: string; // ISO 8601
}

export interface Week {
  id: string;
  householdId: string; // partition key
  label: string; // e.g. "Week of 2024-01-15"
  startDate: string; // ISO 8601 date (YYYY-MM-DD)
  createdAt: string; // ISO 8601
  archived: boolean;
}

export interface Meal {
  id: string;
  weekId: string; // partition key
  text: string;
  order: number; // display order for drag-and-drop
}

export interface GroceryItem {
  id: string;
  weekId: string; // partition key
  text: string;
  completed: boolean;
  createdAt: string; // ISO 8601
  updatedAt: string; // ISO 8601
}
