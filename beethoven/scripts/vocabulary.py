"""
ISL Vocabulary Management
Handles ISL sign vocabulary and mappings
"""

# Initial vocabulary (50 most common ISL signs)
ISL_VOCABULARY_50 = {
    0: {"sign": "A", "english": "A", "category": "alphabet"},
    1: {"sign": "B", "english": "B", "category": "alphabet"},
    2: {"sign": "C", "english": "C", "category": "alphabet"},
    # ... (A-Z alphabets)
    26: {"sign": "HELLO", "english": "hello", "category": "greeting"},
    27: {"sign": "THANK_YOU", "english": "thank you", "category": "emotion"},
    28: {"sign": "YES", "english": "yes", "category": "affirmation"},
    29: {"sign": "NO", "english": "no", "category": "negation"},
    30: {"sign": "PLEASE", "english": "please", "category": "request"},
    31: {"sign": "SORRY", "english": "sorry", "category": "emotion"},
    32: {"sign": "GOOD", "english": "good", "category": "adjective"},
    33: {"sign": "BAD", "english": "bad", "category": "adjective"},
    34: {"sign": "HAPPY", "english": "happy", "category": "emotion"},
    35: {"sign": "SAD", "english": "sad", "category": "emotion"},
    36: {"sign": "LOVE", "english": "love", "category": "emotion"},
    37: {"sign": "HATE", "english": "hate", "category": "emotion"},
    # ... continue with more signs
}

# Extended vocabulary (100+ signs)
# Would include verbs, nouns, adjectives, common phrases

class ISLVocabulary:
    """Manages ISL vocabulary and translations"""
    
    def __init__(self, vocabulary_dict):
        self.vocabulary = vocabulary_dict
        self.reverse_map = {v["english"]: k for k, v in vocabulary_dict.items()}
    
    def get_english_translation(self, class_index):
        """Get English translation for a recognized sign"""
        if class_index in self.vocabulary:
            return self.vocabulary[class_index]["english"]
        return None
    
    def get_sign_name(self, class_index):
        """Get ISL sign name"""
        if class_index in self.vocabulary:
            return self.vocabulary[class_index]["sign"]
        return None
    
    def get_category(self, class_index):
        """Get sign category"""
        if class_index in self.vocabulary:
            return self.vocabulary[class_index]["category"]
        return None
    
    def get_class_index_by_english(self, english_text):
        """Get class index from English translation"""
        return self.reverse_map.get(english_text.lower())
    
    def get_vocabulary_size(self):
        """Get total vocabulary size"""
        return len(self.vocabulary)
    
    def get_signs_by_category(self, category):
        """Get all signs in a specific category"""
        return [
            (idx, item["sign"]) 
            for idx, item in self.vocabulary.items() 
            if item["category"] == category
        ]
