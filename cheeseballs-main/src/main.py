from transaction_parser import TransactionParser

def process_transaction_file(filename: str):
    parser = TransactionParser()
    
    with open(filename, 'r') as f:
        content = f.read()
    
    fun_purchases = parser.parse_transaction_file(content)
    
    # Print fun purchases for demonstration
    for purchase in fun_purchases:
        print(f"🛍️ Fun Purchase at {purchase['merchant']}:")
        print(f"   Item: {purchase['product_name']}")
        print(f"   Price: ${purchase['price']}")
        print(f"   Time: {purchase['purchase_time']}")
        print(f"   Paid with: {purchase['payment_method']}")
        print("---")

if __name__ == "__main__":
    process_transaction_file("transactions.txt") 