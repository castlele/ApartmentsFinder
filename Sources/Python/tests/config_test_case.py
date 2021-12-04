import unittest
from configurations import Configurations


class ConfigurationTestCase(unittest.TestCase):
    def test_init(self):
        full_data_1 = {
            "rooms": [0, 1],
            "location": "Moscow",
            "price": [12000, 24000]
        }

        not_full_data_1 = {
            "location": "Moscow"
        }

        not_full_data_2 = {
            "rooms": [0, 1],
            "price": [0, 24000]
        }

        empty_data = {}

        config_1 = Configurations(full_data_1)
        config_2 = Configurations(not_full_data_1)
        config_3 = Configurations(not_full_data_2)
        config_4 = Configurations(empty_data)

        self.assertEqual(config_1.price, range(12000, 24000))
        self.assertEqual(config_2.price, None)
        self.assertEqual(config_2.location, not_full_data_1["location"])
        self.assertEqual(config_3.location, None)
        self.assertEqual(config_4.location, None)
        self.assertEqual(config_4.price, None)
        self.assertEqual(config_4.rooms, None)


if __name__ == '__main__':
    unittest.main()
