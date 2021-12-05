from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.common.by import By
from utils import Logger, Optional, Any
import enum


class ApartmentsSite(enum.Enum):
    """
    Object represents sites from where apartments can be parsed.
    """
    avito = "https://www.avito.ru/sankt-peterburg/kvartiry"

    def get_apartments_name(self) -> str:
        """
        Gets apartment's *name* from its announcement.

        :return: string which represents html class of apartment's *name* element.
        """
        match self:
            case self.avito:
                return 'link-link-MbQDP'

    def get_apartments_url(self) -> str:
        """
        Gets apartment's *url* from its announcement.

        :return: string which represents html class of apartment's *url* element.
        """
        match self:
            case self.avito:
                return 'link-link-MbQDP'

    def get_apartments_price(self) -> str:
        """
        Gets apartment's *price* from its announcement.

        :return: string which represents html class of apartment's *price* element.
        """
        match self:
            case self.avito:
                return 'price-text-E1Y7h'

    def get_apartments_address(self) -> str:
        """
        Gets apartment's *address* from its announcement.

        :return: string which represents html class of apartment's *address* element.
        """
        match self:
            case self.avito:
                return 'geo-address-QTv9k'

    def get_list_of_apartments(self) -> str:
        """
        Gets list of all apartments from the single page.

        :return: string which represents html class of all apartments.
        """
        match self:
            case self.avito:
                return 'iva-item-root-Nj_hb'

    def get_category(self) -> str:
        """
        Gets category on the web site which represents long time renting.

        :return: string which represents html xpath of the long time renting category.
        """
        match self:
            case self.avito:
                return '//*[@id="app"]/div[3]/div[3]/div[1]/div/div[1]/ul/li/ul/li[5]/div/a'

    def get_rooms(self) -> dict[int: str]:
        """
        Gets switched which toggle different room amount in apartments.

        :return: dictionary where key is an amount of rooms and value is a xpath of the switch.
        """
        match self:
            case self.avito:
                return {
                    0: '//*[@id="app"]/div[3]/div[3]/div[1]/div/div[2]/div[1]/form/div[4]/div/div[2]/div/div/div/div/ul/li[1]/label',
                    1: '//*[@id="app"]/div[3]/div[3]/div[1]/div/div[2]/div[1]/form/div[4]/div/div[2]/div/div/div/div/ul/li[2]/label',
                    2: '//*[@id="app"]/div[3]/div[3]/div[1]/div/div[2]/div[1]/form/div[4]/div/div[2]/div/div/div/div/ul/li[3]/label',
                    3: '//*[@id="app"]/div[3]/div[3]/div[1]/div/div[2]/div[1]/form/div[4]/div/div[2]/div/div/div/div/ul/li[4]/label',
                    4: '//*[@id="app"]/div[3]/div[3]/div[1]/div/div[2]/div[1]/form/div[4]/div/div[2]/div/div/div/div/ul/li[5]/label',
                    5: '//*[@id="app"]/div[3]/div[3]/div[1]/div/div[2]/div[1]/form/div[4]/div/div[2]/div/div/div/div/ul/li[6]/label'
                }

    def get_price(self) -> tuple[str, str]:
        """
        Gets two text field which represents lower price bound and upper price bound.

        :return: tuple of two strings.
        First string is a xpath representation of the lower price bound and second string is a xpath representation of the upper price bound.
        """
        lower_path = str()
        upper_path = str()

        match self:
            case self.avito:
                lower_path = '/html/body/div[1]/div[3]/div[3]/div[1]/div/div[2]/div[1]/form/div[5]/div/div[2]/div/div/div/div/div/div/label[1]'
                upper_path = '/html/body/div[1]/div[3]/div[3]/div[1]/div/div[2]/div[1]/form/div[5]/div/div[2]/div/div/div/div/div/div/label[2]'

        return lower_path, upper_path

    def get_apply_button(self) -> str:
        """
        Gets button, that applies all changes in configuration.

        :return: string, which represents xpath of the button element.
        """
        match self:
            case self.avito:
                return '//*[@id="app"]/div[3]/div[3]/div[1]/div/div[2]/div[2]/div/button[1]'


class Apartment:
    """
    Model which represents apartment's info.
    """
    _web_element: WebElement = None
    _site: ApartmentsSite = None
    _logger: Optional[Logger] = None

    name: Optional[str] = None
    url: Optional[str] = None
    price: Optional[float] = None
    additional_info: Optional[str] = None
    address: Optional[str] = None

    def __init__(self, element: WebElement, site: ApartmentsSite, logger: Optional[Logger] = None):
        self._web_element = element
        self._site = site
        self._logger = logger

        self.parse_element()

    def __repr__(self):
        return '{\n' \
                f'\t"name": {self.name}\n' \
                f'\t"url": {self.url}\n' \
                f'\t"price": {self.price}\n' \
                f'\t"additional_info": {self.additional_info}\n' \
                f'\t"address": {self.address}\n' \
               '}'

    def as_dict(self) -> dict[str, Optional[Any]]:
        """
        Represents current model as a dictionary.

        :return: dictionary where key is a parameter name and value is a parameter's value.
        """
        return {
            "name": self.name,
            "url": self.url,
            "price": self.price,
            "additional_info": self.additional_info,
            "address": self.address
        }

    def parse_element(self):
        """
        Parses needed info about apartment from the web site and assigns it to the properties.
        """
        self._parse_name()
        self._parse_url()
        self._parse_price()
        self._parse_address()

    def _parse_name(self):
        """
        Parsed *name* of the apartments from the web. If the error was thrown it is logged by the logger and nothing assigns.
        """
        try:
            element = self._web_element.find_element(By.CLASS_NAME, self._site.get_apartments_name())
            self.name = element.get_attribute("title")
        except Exception as e:
            self._throw_error(e)

    def _parse_url(self):
        """
        Parsed *url* of the apartments from the web. If the error was thrown it is logged by the logger and nothing assigns.
        """
        try:
            element = self._web_element.find_element(By.CLASS_NAME, self._site.get_apartments_url())
            self.url = element.get_attribute("href")
        except Exception as e:
            self._throw_error(e)

    def _parse_price(self):
        """
        Parsed *price* of the apartments from the web. If the error was thrown it is logged by the logger and nothing assigns.
        """
        try:
            element = self._web_element.find_element(By.CLASS_NAME, self._site.get_apartments_price())
            self.price = element.text
        except Exception as e:
            self._throw_error(e)

    def _parse_address(self):
        """
        Parsed *address* of th apartments from the web. If the error was thrown it is logged by the logger and nothing assigns.
        """
        try:
            element = self._web_element.find_element(By.CLASS_NAME, self._site.get_apartments_address())
            self.address = element.text
        except Exception as e:
            self._throw_error(e)

    def _throw_error(self, e: Exception):
        """
        If logger is not None logs the exception.
        :param e: Exception which should be logged
        """
        if self._logger:
            self._logger.out(f"Error was throws: {e}")
