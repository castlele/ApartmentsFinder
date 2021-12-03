from datetime import datetime
import utils


class _Logger:
    """
    Abstract base class which should be inherited to represent a new Logger system
    """
    @staticmethod
    def out(data: utils.Any):
        """
        Logs given data.

        :param data: Any data type.
        """
        pass

    @staticmethod
    def take_time_stamp() -> str:
        """
        Gets time current time stamp in the following format: 01-12-2021 10:37:40.
        Method can be used in logging system.

        :return: current date and time as a sting
        """
        return datetime.now().strftime("%d-%M-%Y %H:%M:%S")


class StandardCLLogger(_Logger):
    """
    Logger which returns logs into the terminal
    """
    @staticmethod
    def out(data: utils.Any):
        current_time = _Logger.take_time_stamp()
        print(f"[{current_time}]: {data}")
