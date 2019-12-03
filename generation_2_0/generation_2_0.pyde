import numpy as np 
import pandas as pd 
import tensorflow as tf
from tqdm import tqdm
import midi_manipulation as mm

lowest_note = mm.lowerBound
highest_note = mm.upperBound
note_range = highest_note - lowest_note
