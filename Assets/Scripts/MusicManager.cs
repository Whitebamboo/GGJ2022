using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicManager : CSingletonMono<MusicManager>
{
    public class AudioBuffer
    {
        public string name;
        public float time;
    }

    public AudioSource bgmAudioSource;
    public AudioSource sfxAudioSource;

    public float bufferTime;
    public List<AudioBuffer> audioBuffers = new List<AudioBuffer>();


    void Update()
    {
        if (audioBuffers.Capacity > 0)
        {
            foreach (AudioBuffer b in audioBuffers)
            {
                b.time -= Time.deltaTime;
            }
        }
    }
    public void PlayClip(AudioClip clip, float delay = 0)
    {
        if (clip == null)
        {
            Debug.Log("Null Clip");
            return;
        }

        if (audioBuffers.Capacity > 0)
        {
            foreach (AudioBuffer b in audioBuffers)
            {
                if (clip.name == b.name && b.time > 0)
                {
                    return;
                }
                else if (clip.name == b.name)
                {
                    b.time = bufferTime;
                }
            }
        }

        if (delay > 0)
        {
            sfxAudioSource.clip = clip;
            sfxAudioSource.PlayDelayed(delay);
        }
        else
        {
            sfxAudioSource.PlayOneShot(clip);
        }

        AudioBuffer buffer = new AudioBuffer();
        buffer.name = clip.name;
        buffer.time = bufferTime;
        audioBuffers.Add(buffer);
    }
}
