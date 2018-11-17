import matplotlib.pyplot as plt
import numpy as np
import scipy.stats

def get_x(mu, sigma, step):
    start = mu-3*sigma
    stop = mu+3*sigma
    return np.arange(start, stop, 0.1)

def exercise_4_linear_transformation(x):
    return x * 2 + 2

def exercise_4_non_linear_transformation(x):
    return x ** 2 + 2

# Exercise 1
# # samples = 1000
# # n = 10
# # sum_vector = np.random.uniform(0, 1, samples)
# # plt.figure(1)
# # plt.hist(sum_vector, bins=25, edgecolor='black', density=True)
# # plt.title("Uniform distribution for the interval [0,1)")
# # plt.show()
# # for i in range(n-1):
# #     sum_vector += np.random.uniform(0, 1, samples)
# # sum_vector /= n
# # plt.figure(2)
# # plt.hist(sum_vector, bins=25, edgecolor='black', density=True)
# # plt.title("Distribution of the sum of " + str(n) + " uniform [0,1) random variables")
# # plt.show()

# Exercise 2
# # mu1, sigma1 = 1, 1 
# # mu2, sigma2 = 4, 2
# # mu3, sigma3 = 5, 3
# # n_samples = 10000
# # normal_1_1 = sigma1 * np.random.randn(n_samples) + mu1
# # normal_4_2 = sigma2 * np.random.randn(n_samples) + mu2
# # normal_5_3 = sigma3 * np.random.randn(n_samples) + mu3
# # x_1_1 = get_x(mu1, sigma1, .1)  
# # x_4_2 = get_x(mu2, sigma2, .1)
# # x_5_3 = get_x(mu3, sigma3, .1) 

# # sum_of_normals = (normal_1_1 + normal_4_2)
# # pdf_1_1 = scipy.stats.norm.pdf(x_1_1, 1, 1)
# # pdf_4_2 = scipy.stats.norm.pdf(x_4_2, 4, 2)
# # pdf_5_3 = scipy.stats.norm.pdf(x_5_3, 5, 3)
# # convolution = np.convolve(pdf_1_1, pdf_4_2)
# # convolution = convolution * 0.1 # multiply it by the step

# # plt.figure(1)
# # # plt.hist(sum_of_normals, bins=n_samples//100, edgecolor='black', density=True, stacked=True)
# # plt.hist(normal_5_3, bins = n_samples//100, edgecolor='black', density=True, stacked=True)
# # plt.plot(x_5_3[:-1], convolution, 'r', label="Convolution")
# # plt.plot(x_1_1, pdf_1_1, 'g', label="N(1,1)")
# # plt.plot(x_4_2, pdf_4_2, 'b', label="N(4,2)")
# # plt.plot(x_5_3, pdf_5_3, 'm', label="N(5,3)")
# # plt.title("Convolution of gaussians")
# # plt.legend()
# # plt.show()

# Exercise 3
# # mu1, sigma1 = 1, 1
# # mu2, sigma2 = 4, 2
# # n_samples = 1000

# # # PDF generation
# # weighted_sigma = sigma1 ** 2 * sigma2 ** 2 / (sigma1 ** 2 + sigma2 ** 2)
# # weighted_mu = (sigma2 ** 2 * mu1 + sigma1 ** 2 * mu2) / (sigma1 ** 2 + sigma2 ** 2)
# # x = np.arange(-5, 10, .1)
# # pdf_1_1 = scipy.stats.norm.pdf(x, 1, 1)
# # pdf_4_2 = scipy.stats.norm.pdf(x, 4, 2)
# # pdf_weighted = scipy.stats.norm.pdf(x, weighted_mu, weighted_sigma)
# # pdf_product = pdf_1_1 * pdf_4_2

# # # Normalization
# # pdf_product /= sum(pdf_product)
# # pdf_1_1 /= sum(pdf_1_1)
# # pdf_4_2 /= sum(pdf_4_2)
# # pdf_weighted /= sum(pdf_weighted)

# # # Plotting
# # plt.figure(2)
# # plt.plot(x, pdf_product, 'red', label="Product")
# # plt.plot(x, pdf_1_1, 'blue', label = "N(1,1)")
# # plt.plot(x, pdf_4_2, 'lime', label='N(4,2)')
# # plt.plot(x, pdf_weighted, 'cyan', label="weighted pdf")
# # plt.title("Weighted average: Product of gaussians")
# # plt.legend(loc='best')
# # plt.show()

# # print(pdf_product)
# # print(pdf_weighted)

# Exercise 4
mu1, sigma1 = 1, 1
n_samples = 1024
normal_1_1 = sigma1 * np.random.randn(n_samples) + mu1
linear_transformation = exercise_4_linear_transformation(normal_1_1)
non_linear_transformation = exercise_4_non_linear_transformation(normal_1_1)
x = get_x(4, 4, 0.1)
xr = list(reversed(x))
pdf_4_4 = scipy.stats.norm.pdf(x, 4, 4)
pdf_4_2 = scipy.stats.norm.pdf(x, 4, 2)
pdf_1_1 = scipy.stats.norm.pdf(x, 1, 1)
plt.figure(0)
plt.plot(x, exercise_4_non_linear_transformation(x), 'black')
plt.title("Linear transformation y = 2x + 2")
plt.figure(1)
plt.plot(x, pdf_1_1, 'cyan')
plt.title("N(1,1) PDF")
plt.figure(2)
transformed = exercise_4_linear_transformation(pdf_1_1)
# plt.hist(linear_transformation, bins=n_samples//2**6, edgecolor='black', density=True, stacked=True)
# plt.plot(x, pdf_4_2, 'lime', label='N(4,2)')
# plt.plot(x, pdf_4_4, 'cyan', label='N(4,4)')
plt.hist(non_linear_transformation, bins=n_samples//2**6, edgecolor='black', density=True, stacked=True)
plt.legend(loc='best')
# plt.title("PDFs compared to samples histogram")
plt.title("Histogram for non-linear transformation")
plt.show()