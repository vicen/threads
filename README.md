# Matlab code to run the experiments of the paper


Pablo Aragón, Vicenç Gómez, and Andreas Kaltenbrunner<br>
[To Thread or Not to Thread: The Impact of Conversation Threading on Online Discussion](https://ojs.aaai.org/index.php/ICWSM/article/download/14880/14730/18399)<br>
Proceedings of the Eleventh International AAAI Conference on Web and Social Media (ICWSM 2017)

## Useful Information

This code runs under Matlab 2018. No tested on earlier/later versions, but it should work as well.
Te file `test_all.m` contains some information to run the scripts.
The directory data contains sample data.

- `compact_posts_bp_ok.mat`: a sample of `7485` discussion threads from from barrapunto to test the model without reciprocity/authorships
- `2015-03.mat`: a sample of `1093` discussion threads from meneame to test the model with reciprocity/authorships

In an Intel(R) Core(TM) i7-4930K CPU @ 3.40GHz, the model without reciprocity (`comb=FULL_MODEL'`) takes about `5` seconds to converge over the fist dataset, whereas the model with reciprocity/authorships `comb = 'FULL_MODEL_AUTHORS_0'` takes `3.5` minutes to converge on the second dataset.
