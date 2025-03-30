from typing import Dict, List, Optional
import json
from datetime import datetime
import pytz

class TransactionParser:
    def __init__(self):
        self.products_db = self._load_json("products.json")
        self.nutrition_db = self._load_json("nutrition.json")
        self.vitamins_db = self._load_json("vitamins.json")
        self.allergies_db = self._load_json("allergies.json")

    def _load_json(self, filename: str) -> Dict:
        try:
            with open(filename, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Warning: {filename} not found. Using empty dictionary.")
            return {}

    def parse_transaction_file(self, content: str) -> List[Dict]:
        """Parse the transaction file content and extract relevant purchase data"""
        try:
            data = json.loads(content)
            fun_purchases = []
            
            for transaction in data.get("transactions", []):
                # Get transaction datetime and convert to local time
                tx_datetime = datetime.fromisoformat(transaction["datetime"].replace('Z', '+00:00'))
                local_time = tx_datetime.astimezone(pytz.timezone('America/New_York'))
                
                # Extract payment method details
                payment_info = self._get_payment_info(transaction["payment_methods"])
                
                # Process each product in the transaction
                for product in transaction["products"]:
                    purchase_data = {
                        "merchant": data["merchant"]["name"],
                        "product_name": product["name"],
                        "price": product["price"]["total"],
                        "purchase_time": local_time.strftime("%I:%M %p"),
                        "payment_method": payment_info,
                        "url": product["url"]
                    }
                    fun_purchases.append(purchase_data)
            
            return fun_purchases
        except json.JSONDecodeError:
            print("Error: Invalid JSON format in transaction file")
            return []
        
    def _get_payment_info(self, payment_methods: List[Dict]) -> str:
        """Extract and format payment method information"""
        if not payment_methods:
            return "Unknown payment method"
        
        # Get the first payment method's details
        payment = payment_methods[0]
        return f"{payment['brand']} ending in {payment['last_four']}"

    def is_fun_purchase(self, product_name: str) -> bool:
        """
        Determine if a purchase is 'fun' based on product name and time
        This is a simple implementation - you might want to expand this logic
        """
        fun_keywords = [
            "snack", "candy", "game", "toy", "entertainment",
            "pizza", "burger", "ice cream", "chocolate",
            "energy drink", "red bull", "monster"
        ]
        return any(keyword in product_name.lower() for keyword in fun_keywords) 