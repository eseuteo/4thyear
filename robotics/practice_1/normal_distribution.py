import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
import numpy as np 

def f(x, mu, sigma):
    sigma2 = sigma**2
    return (1 / np.sqrt(2 * np.pi * sigma2) * np.exp((-(x-mu)**2)/2*(sigma2)))

def n_for_desired_step(start, stop, step):
    return (stop - start) // step + 1

def evaluate_gaussian(mu, sigma, x):
    return f(x, mu, sigma)

# Exercise 1
# # mu, sigma = 2, 1
# # x = np.linspace(-5, 5, n_for_desired_step(-5, 5, 0.1))
# # y = f(x, mu, sigma)
# # plt.figure(1)
# # plt.title("Gaussian curve for mu = 2, sigma = 1")
# # plt.plot(x, y)
# # plt.show()

# Exercise 2
# Same as exercise 1 but using evaluate_gaussian

# Exercise 3
# # mu, sigma = 2, 2
# # samples = 100
# # x = sigma * np.random.randn(samples) + mu
# # y = np.zeros(samples, dtype=int)
# # plt.figure(2)
# # plt.title("Sampling of a Normal distribution with mu = 2 and sigma = 2")
# # plt.plot(x,y,'b.',2,0,'rx')
# # plt.show()

# Exercise 4
samples_sizes = [100, 500, 1000]
mu, sigma = 2, 2
for samples in samples_sizes:
    x = sigma * np.random.randn(samples) + mu
    plt.figure(samples)
    bins = plt.hist(x, bins=samples//10, edgecolor='black', density=True)
    y = mlab.normpdf(bins[1], mu, sigma)
    plt.plot(bins[1], y, 'r')
    plt.title("Histogram for " + str(samples) + " samples with mu = 2 and sigma = 2")
    plt.show()
