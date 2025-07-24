import os
import torch
import pandas as pd
import numpy as np
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from sentence_transformers import SentenceTransformer, util
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FinancialChatBot:
    def __init__(self, schemes_df, model_name="openchat/openchat_3.5", device=None):
        """
        Initialize the financial chatbot with OpenChat model.
        
        Args:
            schemes_df: DataFrame containing scheme information
            model_name: Name of the OpenChat model to use
            device: Device to run the model on ('cuda', 'cpu', etc.)
        """
        self.schemes_df = schemes_df
        self.model_name = model_name
        
        # Set device (cuda if available, else cpu)
        if device is None:
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            self.device = device
            
        logger.info(f"Using device: {self.device}")
        logger.info(f"Loading model: {self.model_name}")
        
        # Initialize sentence transformer for embedding schemes
        self.sentence_model = SentenceTransformer('paraphrase-MiniLM-L6-v2')
        
        # Create embeddings for all schemes
        self._prepare_scheme_embeddings()
        
        # Load OpenChat model and tokenizer
        self._setup_model()
        
        logger.info("FinancialChatBot initialization complete")
        
    def _prepare_scheme_embeddings(self):
        """Create embeddings for all schemes"""
        logger.info("Creating embeddings for schemes")
        
        # Create text blobs for each scheme
        self.schemes_df['text_blob'] = (
            self.schemes_df['scheme_goal'].fillna('') + ". " +
            self.schemes_df['eligibility'].fillna('') + ". " +
            self.schemes_df['benefits'].fillna('') + ". " +
            self.schemes_df['total_returns'].fillna('') + ". " +
            self.schemes_df['time_duration'].fillna('') + ". " +
            self.schemes_df['application_process'].fillna('')
        )
        
        # Create embeddings
        self.scheme_texts = self.schemes_df['text_blob'].tolist()
        self.scheme_embeddings = self.sentence_model.encode(
            self.scheme_texts, 
            convert_to_tensor=True
        )
        
        logger.info(f"Created embeddings for {len(self.scheme_texts)} schemes")
        
    def _setup_model(self):
        """Load and configure the OpenChat model"""
        logger.info(f"Loading OpenChat model: {self.model_name}")
        
        # Load tokenizer and model with optimizations
        self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
        
        # Use lower precision for faster inference on GPU
        model_dtype = torch.float16 if self.device == "cuda" else torch.float32
        
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_name,
            torch_dtype=model_dtype,
            device_map="auto",
            low_cpu_mem_usage=True
        )
        
        # Create text generation pipeline with optimized settings
        self.pipe = pipeline(
            "text-generation",
            model=self.model,
            tokenizer=self.tokenizer,
            max_new_tokens=512,
            temperature=0.7,
            top_p=0.95,
            repetition_penalty=1.15,
            do_sample=True
        )
        
        logger.info("OpenChat model setup complete")
        
    def _find_relevant_schemes(self, query, top_k=3):
        """Find schemes most relevant to the query"""
        # Encode query
        query_embedding = self.sentence_model.encode(query, convert_to_tensor=True)
        
        # Calculate similarities
        similarities = util.pytorch_cos_sim(
            query_embedding, 
            self.scheme_embeddings
        )[0].cpu().numpy()
        
        # Get top indices
        top_indices = np.argsort(similarities)[::-1][:top_k]
        return self.schemes_df.iloc[top_indices], similarities[top_indices]
    
    def _format_scheme_info(self, scheme, lang="en"):
        """Format a scheme's details into a readable string"""
        # Helper function to get the language-specific column if it exists
        def get_col(col, lang):
            lang_col = f"{col}_{lang}"
            if lang_col in scheme and pd.notna(scheme[lang_col]):
                return scheme[lang_col]
            return scheme[col] if pd.notna(scheme[col]) else ""
        
        # Build a formatted string with scheme details
        result = f"Scheme: {get_col('scheme_name', lang)}\n"
        
        if get_col('scheme_goal', lang):
            result += f"Goal: {get_col('scheme_goal', lang)}\n"
            
        if get_col('eligibility', lang):
            result += f"Eligibility: {get_col('eligibility', lang)}\n"
            
        if get_col('benefits', lang):
            result += f"Benefits: {get_col('benefits', lang)}\n"
            
        if get_col('total_returns', lang):
            result += f"Returns: {get_col('total_returns', lang)}\n"
            
        if get_col('time_duration', lang):
            result += f"Duration: {get_col('time_duration', lang)}\n"
            
        if scheme.get('scheme_website'):
            result += f"Website: {scheme['scheme_website']}\n"
            
        return result
        
    def get_response(self, query, language="en"):
        """
        Get a response from the chatbot for a user query.
        
        Args:
            query: The user's question or request
            language: The language code ('en', 'hi', 'mr')
            
        Returns:
            str: The chatbot's response
        """
        logger.info(f"Processing query in {language}: {query}")
        
        # Find relevant schemes
        relevant_schemes, _ = self._find_relevant_schemes(query, top_k=3)
        
        # Format schemes information
        schemes_info = ""
        for _, scheme in relevant_schemes.iterrows():
            schemes_info += self._format_scheme_info(scheme, lang=language) + "\n\n"
        
        # Set language for response
        language_instruction = {
            "en": "Respond in English.",
            "hi": "Respond in Hindi.",
            "mr": "Respond in Marathi."
        }.get(language, "Respond in English.")
        
        # Create prompt with context
        prompt = f"""
{language_instruction}

You are a financial advisor specializing in government schemes and financial literacy. 
Use the following information about schemes to answer the user's question.
If the information doesn't contain the answer, explain what you know about the financial 
concept but clarify that you don't have specific scheme details for that query.

SCHEMES INFORMATION:
{schemes_info}

USER QUESTION: {query}

ANSWER:
"""
        
        # Generate response
        try:
            # Get response from model
            result = self.pipe(prompt, max_new_tokens=512)[0]['generated_text']
            
            # Extract just the answer part (after "ANSWER:")
            answer_parts = result.split("ANSWER:")
            if len(answer_parts) > 1:
                answer = answer_parts[1].strip()
            else:
                answer = result
            
            logger.info("Successfully generated response")
            return answer
        except Exception as e:
            logger.error(f"Error generating response: {str(e)}")
            return f"I encountered an error while processing your question. Please try again later."

# Helper function to create a chatbot instance
def create_financial_chatbot(schemes_df, model_name="openchat/openchat_3.5"):
    """Helper function to create and return a FinancialChatBot instance"""
    return FinancialChatBot(schemes_df, model_name)
