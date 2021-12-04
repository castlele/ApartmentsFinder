from utils import Any, Optional


class Configurations:
    """
    Configurations which should be followed while filtering the apartments.
    """
    price: Optional[range] = None
    location: Optional[str] = None
    rooms: Optional[list[int]] = None

    def __init__(self, json_data: dict[Any]):
        if "price" in json_data:
            price = json_data["price"]
            self.price = range(price[0], price[1])

        if "location" in json_data:
            location = json_data["location"]
            self.location = location

        if "rooms" in json_data:
            rooms = json_data["rooms"]
            self.rooms = rooms

    def __repr__(self):
        return f"Config:\n\t{self.price=}\n\t{self.location=}\n\t{self.rooms=}"
