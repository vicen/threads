# Matlab code to run the experiments of the paper


Pablo Aragón, Vicenç Gómez, and Andreas Kaltenbrunner<br>
[To Thread or Not to Thread: The Impact of Conversation Threading on Online Discussion](https://ojs.aaai.org/index.php/ICWSM/article/download/14880/14730/18399)<br>
Proceedings of the Eleventh International AAAI Conference on Web and Social Media (ICWSM 2017)

## Instructions

This code runs under Matlab 2018. No tested on earlier or later versions, but it should work as well.
Te file test_all.m contains some information to run the scripts.
The directory data contains sample data.

- compact_posts_bp_ok.mat
- 2015-03.mat
from barrapunto (file compact_posts_bp_ok.mat) and meneame (file 2015-03.mat) threads.

The model with authorships comb = 'FULL_MODEL_AUTHORS_0' takes considerably longer to run.
In a standard desktop machine, it takes about 5 minuts to run one optimization with 320 posts.


