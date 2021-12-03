from selenium import webdriver
from selenium.webdriver.safari.webdriver import WebDriver
from selenium.webdriver.common.by import By
from logger import StandardCLLogger
from utils import Any, Logger, Optional
import apartments as aparts
import json
import time


class Configurations:
    """
    Configurations which should be followed while filtering the apartments.
    """
    price: range = None
    location: str = None
    rooms: list[int] = None

    def __init__(self, json_data: dict[Any]):
        self.price = range(json_data["price"][0], json_data["price"][1])
        self.location = json_data["location"]
        self.rooms = json_data["rooms"]

    def __repr__(self):
        return f"Config:\n\t{self.price=}\n\t{self.location=}\n\t{self.rooms=}"


class ParserDelegate:
    """
    Object helps in logging different events while parsing the apartments.
    """
    _logger: Optional[Logger]

    def __init__(self, logger: Optional[Logger] = None):
        self._logger = logger

    def get_logger(self) -> Logger:
        return self._logger

    def web_driver_was_configured(self, web_driver: WebDriver):
        self._logger.out(f"Web driver was configured with: {web_driver}")

    def web_site_was_configured(self, site: str):
        self._logger.out(f"Web site was configured: {site}")

    def rooms_were_set(self, rooms_count: list[int]):
        self._logger.out(f"Rooms were set with {rooms_count}")

    def price_was_set(self, price_range: range):
        self._logger.out(f"Price was set to range from {price_range.start} to {price_range.stop}")

    def configuration_was_completed(self):
        self._logger.out("Configuration was completed")

    def starting_parsing_apartments(self):
        self._logger.out("Starting parsing apartments")

    def apartment_was_parsed(self, apartment: aparts.Apartment):
        self._logger.out(f"Apartment was parsed: {apartment}".encode("ascii", "replace"))

    def all_apartments_were_parsed(self, apartments: aparts.Apartment, pages: int):
        self._logger.out(f"All apartments were parsed.\nApartments parsed: {apartments}\nPages seen: {pages}".encode("ascii", "replace"))

    def parser_was_deallocated(self):
        self._logger.out("Parser was deallocated")

    def error_was_thrown(self, error: Exception):
        self._logger.out(f"Error occur: {error}")


class SiteParser:
    """
    Configures, filters and parses the apartments from the given web site.
    """
    _configuration: Configurations
    _site: aparts.ApartmentsSite
    _driver: WebDriver
    _delegate: Optional[ParserDelegate]

    def __init__(self,
                 config: Configurations,
                 site: aparts.ApartmentsSite,
                 delegate: Optional[ParserDelegate] = None,
                 web_driver: WebDriver = webdriver.Safari()):
        self._configuration = config
        self._site = site
        self._delegate = delegate
        self._setup_driver(web_driver)

    def _setup_driver(self, web_driver: WebDriver):
        self._driver = web_driver
        self._driver.set_window_size(1024, 768)
        self._driver.implicitly_wait(15)

        if self._delegate:
            self._delegate.web_driver_was_configured(web_driver)

    def __del__(self):
        self._driver.close()

        if self._delegate:
            self._delegate.parser_was_deallocated()

    def get_apartments(self) -> list[aparts.Apartment]:
        """
        Gets list of apartments.
        Method have to be called before setting the configuration, other wise behavior is unexpected.

        :return: list of apartments.
        """
        if self._delegate:
            self._delegate.starting_parsing_apartments()

        list_of_web_elements = self._get_list_of_web_elements()

        if not list_of_web_elements:
            if self._delegate:
                self._delegate.all_apartments_were_parsed(list_of_web_elements, 1)
            return []

        list_of_apartments = self._get_list_of_apartments(list_of_web_elements)

        if self._delegate:
            self._delegate.all_apartments_were_parsed(list_of_apartments, 1)

        return list_of_apartments

    def _get_list_of_web_elements(self) -> list:
        """
        Gets list of web elements where each element represents a single apartment's element.

        :return: list of web elements.
        """
        try:
            list_of_web_elements = self._driver.find_elements(By.CLASS_NAME, self._site.get_list_of_apartments())
            return list_of_web_elements
        except Exception as e:
            if self._delegate:
                self._delegate.error_was_thrown(e)
            return []

    def _get_list_of_apartments(self, list_of_web_elements: list) -> list[aparts.Apartment]:
        """
        Gets list of apartments from the given web elements.

        :param list_of_web_elements: list of web elements. Each element represents an apartment.
        :return: list of apartments which were parsed from the web elements.
        """
        list_of_apartments = list()

        for element in list_of_web_elements:
            logger = self._delegate.get_logger() if self._delegate else None
            apartment = aparts.Apartment(element, self._site, logger)
            list_of_apartments.append(apartment)

            if self._delegate:
                self._delegate.apartment_was_parsed(apartment)
        return list_of_apartments

    def set_config(self) -> bool:
        """
        Applies given config to the web site.

        :return: True if configurations were set without errors, otherwise False
        """
        try:
            self._set_website()
            self._set_rooms()
            self._set_price()

            if self._delegate:
                self._delegate.configuration_was_completed()

            return True

        except Exception as e:
            if self._delegate:
                self._delegate.error_was_thrown(e)

            return False

    def _set_website(self):
        """
        Configures given web site and necessary category.
        """
        self._driver.get(self._site.value)
        self._set_category()

        if self._delegate:
            self._delegate.web_site_was_configured(self._site.value)

    def _set_category(self):
        """
        Configures long renting on the web site.
        """
        needed_category_path = self._site.get_category()
        needed_category = self._driver.find_element(By.XPATH, needed_category_path)
        needed_category.click()

    def _set_rooms(self):
        """
        Configures amount of rooms on the web site according to the given configuration.
        """
        if len(self._configuration.rooms) == 0:
            radio_button_path = self._site.get_rooms()[0]
            radio_button = self._driver.find_element(By.XPATH, radio_button_path)
            radio_button.click()

            if self._delegate:
                self._delegate.rooms_were_set([0])
            return

        for number_of_rooms in self._configuration.rooms:
            radio_button_path = self._site.get_rooms()[number_of_rooms]
            radio_button = self._driver.find_element(By.XPATH, radio_button_path)
            radio_button.click()

        if self._delegate:
            self._delegate.rooms_were_set(self._configuration.rooms)

    def _set_price(self):
        """
        Configures price on the web site according to the given configuration.
        """
        if not self._configuration.price:
            return

        lower_bound_path, upper_bound_path = self._site.get_price()
        lower_bound = self._driver.find_element(By.XPATH, lower_bound_path)
        lower_bound.send_keys(str(self._configuration.price.start))
        upper_bound = self._driver.find_element(By.XPATH, upper_bound_path)
        upper_bound.send_keys(str(self._configuration.price.stop))

        if self._delegate:
            self._delegate.price_was_set(self._configuration.price)

    def deinit(self, timeout: float):
        """
        Deinites the instance of current object and loges it.

        :param timeout: time of timeout before deinitializing.
        """
        time.sleep(timeout)
        del self


def _convert_json_to_dict(json_data: str) -> dict[Any]:
    """
    Private method which converts json data into dict. Uses `json` module.

    :param json_data: json as a string.
    :return: dictionary, where key is a configuration's property as a string and value can be any type.
    """
    data = json.loads(json_data)
    return data


def _convert_apartments_to_json(apartments: list[aparts.Apartment]) -> str:
    """
    Private method which converts apartments' objects into json.

    :param apartments: list of apartments.
    :return: json data as a string
    """
    json_data = json.dumps([apartment.as_dict() for apartment in apartments])
    return json_data


def _make_config(json_data: str) -> Configurations:
    """
    Makes config from the given json data.

    :param json_data: json data as a string.
    :return: `Configurations` object.
    """
    data = _convert_json_to_dict(json_data)
    config = Configurations(data)
    return config


def request(json_data: str) -> str:
    """
    Makes network request and gets apartments filtered by the given config.

    :param json_data: config as a json string.
    :return: json string which represents list of apartments.
    """
    config = _make_config(json_data)
    parser_delegate = ParserDelegate(logger=StandardCLLogger)
    parser = SiteParser(config, aparts.ApartmentsSite.avito, delegate=parser_delegate)

    json_data = ""

    if parser.set_config():
        apartments = parser.get_apartments()
        json_data = _convert_apartments_to_json(apartments)

    parser.deinit(2.5)
    return json_data


if __name__ == "__main__":
    sample_data = '{' \
                  '"fileName":"default",' \
                  '"isHelp":false,' \
                  '"columns":[],' \
                  '"price":[12000,24000],' \
                  '"location":"Moscow",' \
                  '"rooms":[2, 1]' \
                  '}'
    print(request(sample_data))
