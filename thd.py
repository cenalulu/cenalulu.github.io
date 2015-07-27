import multiprocessing
import time


def my_sleep():
    print("Thread Start")
    time.sleep(1)


def main():
    thd_pool = multiprocessing.Pool(processes=3)
    thd_pool.map(my_sleep, range(10))
    thd_pool.close()
    thd_pool.join()

if __name__ == '__main__':
    main()
